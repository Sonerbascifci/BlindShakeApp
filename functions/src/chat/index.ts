import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface ChatMessage {
  id: string;
  senderId: string;
  content: string;
  timestamp: admin.firestore.Timestamp;
  type: "text" | "system" | "reveal_request";
}

interface Match {
  id: string;
  participants: string[];
  status: "anonymous" | "revealed" | "archived";
  anonymousPhaseEnds: admin.firestore.Timestamp;
  revealRequestedBy?: string;
}

/**
 * HTTP Cloud Function: Send a message in an anonymous chat
 */
export const sendMessage = functions.https.onCall(async (data, context) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { matchId, content, type = "text" } = data as {
    matchId: string;
    content: string;
    type?: "text" | "system" | "reveal_request";
  };

  const senderId = context.auth.uid;

  // Validate inputs
  if (!matchId || !content?.trim()) {
    throw new functions.https.HttpsError("invalid-argument", "Match ID and content are required");
  }

  if (content.length > 1000) {
    throw new functions.https.HttpsError("invalid-argument", "Message too long");
  }

  try {
    // Verify user is participant in this match
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Match not found");
    }

    const match = matchDoc.data() as Match;
    if (!match.participants.includes(senderId)) {
      throw new functions.https.HttpsError("permission-denied", "User not participant in this match");
    }

    // Check if match is still active
    if (match.status === "archived") {
      throw new functions.https.HttpsError("failed-precondition", "Match has been archived");
    }

    // Create message document
    const messageData: Omit<ChatMessage, "id"> = {
      senderId,
      content: content.trim(),
      timestamp: admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
      type,
    };

    // Add message to messages subcollection
    const messageRef = db.collection("matches").doc(matchId).collection("messages").doc();
    await messageRef.set({
      id: messageRef.id,
      ...messageData,
    });

    // Update match with last message info
    await db.collection("matches").doc(matchId).update({
      lastMessage: {
        content: type === "text" ? content.trim() : "[System message]",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        senderId,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info("Message sent", {
      matchId,
      senderId,
      messageId: messageRef.id,
      type
    });

    return {
      success: true,
      messageId: messageRef.id,
    };

  } catch (error) {
    functions.logger.error("Error sending message", { matchId, senderId, error });
    throw new functions.https.HttpsError("internal", "Failed to send message");
  }
});

/**
 * HTTP Cloud Function: Request to reveal identities
 */
export const requestReveal = functions.https.onCall(async (data, context) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { matchId } = data as { matchId: string };
  const requesterId = context.auth.uid;

  if (!matchId) {
    throw new functions.https.HttpsError("invalid-argument", "Match ID is required");
  }

  try {
    const matchRef = db.collection("matches").doc(matchId);

    await db.runTransaction(async (transaction) => {
      const matchDoc = await transaction.get(matchRef);
      if (!matchDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Match not found");
      }

      const match = matchDoc.data() as Match;

      // Verify user is participant
      if (!match.participants.includes(requesterId)) {
        throw new functions.https.HttpsError("permission-denied", "User not participant in this match");
      }

      // Check if anonymous phase has ended
      const now = new Date();
      const anonymousEnds = match.anonymousPhaseEnds.toDate();

      if (now < anonymousEnds) {
        throw new functions.https.HttpsError("failed-precondition", "Anonymous phase still active");
      }

      // Check current status
      if (match.status !== "anonymous") {
        throw new functions.https.HttpsError("failed-precondition", "Match is not in anonymous phase");
      }

      // const otherUserId = match.participants.find(id => id !== requesterId)!;

      if (match.revealRequestedBy) {
        // Someone already requested reveal
        if (match.revealRequestedBy === requesterId) {
          throw new functions.https.HttpsError("already-exists", "You already requested reveal");
        } else {
          // Both users want to reveal - proceed with reveal
          transaction.update(matchRef, {
            status: "revealed",
            revealedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Add system message about reveal
          const messageRef = db.collection("matches").doc(matchId).collection("messages").doc();
          transaction.set(messageRef, {
            id: messageRef.id,
            senderId: "system",
            content: "Both users chose to reveal their identities!",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            type: "system",
          });

          return { revealed: true };
        }
      } else {
        // First reveal request
        transaction.update(matchRef, {
          revealRequestedBy: requesterId,
        });

        // Add system message about reveal request
        const messageRef = db.collection("matches").doc(matchId).collection("messages").doc();
        transaction.set(messageRef, {
          id: messageRef.id,
          senderId: "system",
          content: "One user wants to reveal identities. Waiting for the other to decide...",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          type: "system",
        });

        return { revealed: false, waitingForOther: true };
      }
    });

    functions.logger.info("Reveal requested", { matchId, requesterId });

  } catch (error) {
    functions.logger.error("Error requesting reveal", { matchId, requesterId, error });
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", "Failed to process reveal request");
  }
});

/**
 * HTTP Cloud Function: Decline reveal request
 */
export const declineReveal = functions.https.onCall(async (data, context) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { matchId } = data as { matchId: string };
  const userId = context.auth.uid;

  try {
    const matchRef = db.collection("matches").doc(matchId);

    await db.runTransaction(async (transaction) => {
      const matchDoc = await transaction.get(matchRef);
      if (!matchDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Match not found");
      }

      const match = matchDoc.data() as Match;

      // Verify user is participant and can decline
      if (!match.participants.includes(userId)) {
        throw new functions.https.HttpsError("permission-denied", "User not participant in this match");
      }

      if (!match.revealRequestedBy || match.revealRequestedBy === userId) {
        throw new functions.https.HttpsError("failed-precondition", "No reveal request to decline");
      }

      // Archive the match
      transaction.update(matchRef, {
        status: "archived",
        archivedAt: admin.firestore.FieldValue.serverTimestamp(),
        archivedReason: "reveal_declined",
      });

      // Add system message about decline
      const messageRef = db.collection("matches").doc(matchId).collection("messages").doc();
      transaction.set(messageRef, {
        id: messageRef.id,
        senderId: "system",
        content: "One user declined to reveal identities. The chat has ended.",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        type: "system",
      });

      // Clear current match from user profiles
      for (const participantId of match.participants) {
        transaction.update(db.collection("users").doc(participantId), {
          currentMatchId: admin.firestore.FieldValue.delete(),
        });
      }
    });

    functions.logger.info("Reveal declined, match archived", { matchId, userId });

    return { success: true, archived: true };

  } catch (error) {
    functions.logger.error("Error declining reveal", { matchId, userId, error });
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", "Failed to decline reveal");
  }
});

/**
 * Firestore Trigger: Handle match status changes
 */
export const onMatchUpdate = functions.firestore
  .document("matches/{matchId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data() as Match;
    const after = change.after.data() as Match;
    const matchId = context.params.matchId;

    // Handle reveal status change
    if (before.status === "anonymous" && after.status === "revealed") {
      try {
        // Get participant details for reveal
        const participantDocs = await Promise.all(
          after.participants.map(id => db.collection("users").doc(id).get())
        );

        const participantInfo: any = {};
        participantDocs.forEach(doc => {
          if (doc.exists) {
            const userData = doc.data()!;
            participantInfo[doc.id] = {
              displayName: userData.displayName,
              photoURL: userData.photoURL,
              email: userData.email,
            };
          }
        });

        // Update match with revealed participant info
        await db.collection("matches").doc(matchId).update({
          revealedParticipantInfo: participantInfo,
        });

        functions.logger.info("Match revealed, participant info updated", { matchId });

      } catch (error) {
        functions.logger.error("Error handling match reveal", { matchId, error });
      }
    }

    return null;
  });