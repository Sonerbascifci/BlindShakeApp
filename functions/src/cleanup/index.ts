import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const realtimeDb = admin.database();

/**
 * Scheduled function: Auto-archive matches after anonymous phase ends
 * Runs every 5 minutes to check for matches that should be archived
 */
export const autoArchiveExpiredMatches = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    try {
      const now = new Date();
      const batch = db.batch();
      let archivedCount = 0;

      // Query matches where anonymous phase has ended but status is still anonymous
      const expiredMatches = await db
        .collection("matches")
        .where("status", "==", "anonymous")
        .where("anonymousPhaseEnds", "<=", now)
        .get();

      for (const doc of expiredMatches.docs) {
        const matchData = doc.data();
        const timeSinceExpiry = now.getTime() - matchData.anonymousPhaseEnds.toDate().getTime();

        // Auto-archive if 24 hours have passed since anonymous phase ended
        // and no reveal was requested
        if (timeSinceExpiry > 24 * 60 * 60 * 1000) { // 24 hours in milliseconds
          batch.update(doc.ref, {
            status: "archived",
            archivedAt: admin.firestore.FieldValue.serverTimestamp(),
            archivedReason: "auto_expired",
          });

          // Add system message about auto-archive
          const messageRef = doc.ref.collection("messages").doc();
          batch.set(messageRef, {
            id: messageRef.id,
            senderId: "system",
            content: "This chat has been automatically archived after 24 hours of inactivity.",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            type: "system",
          });

          // Clear current match from user profiles
          const participants = matchData.participants as string[];
          for (const participantId of participants) {
            batch.update(db.collection("users").doc(participantId), {
              currentMatchId: admin.firestore.FieldValue.delete(),
            });
          }

          archivedCount++;
        }
      }

      if (archivedCount > 0) {
        await batch.commit();
      }

      functions.logger.info(`Auto-archived ${archivedCount} expired matches`);
      return null;

    } catch (error) {
      functions.logger.error("Error in auto-archive function", { error });
      return null;
    }
  });

/**
 * Scheduled function: Clean up old archived matches and messages
 * Runs daily to remove very old data
 */
export const cleanupOldData = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - 30); // 30 days ago

      let deletedMatches = 0;
      let deletedMessages = 0;

      // Query archived matches older than 30 days
      const oldMatches = await db
        .collection("matches")
        .where("status", "==", "archived")
        .where("archivedAt", "<=", cutoffDate)
        .limit(100) // Process in batches to avoid timeouts
        .get();

      // Delete old matches and their messages
      for (const matchDoc of oldMatches.docs) {
        // Delete all messages in this match
        const messages = await matchDoc.ref.collection("messages").get();
        const messageDeleteBatch = db.batch();

        messages.docs.forEach(messageDoc => {
          messageDeleteBatch.delete(messageDoc.ref);
          deletedMessages++;
        });

        if (messages.docs.length > 0) {
          await messageDeleteBatch.commit();
        }

        // Delete the match document
        await matchDoc.ref.delete();
        deletedMatches++;
      }

      functions.logger.info("Cleanup completed", {
        deletedMatches,
        deletedMessages,
        cutoffDate: cutoffDate.toISOString()
      });

      return null;

    } catch (error) {
      functions.logger.error("Error in cleanup function", { error });
      return null;
    }
  });

/**
 * Scheduled function: Clean up stale active shakers
 * Runs every minute to remove users who stopped shaking
 */
export const cleanupStaleShakers = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async () => {
    try {
      const now = Date.now();
      const staleThreshold = 60000; // 60 seconds
      let cleanedCount = 0;

      const shakersRef = realtimeDb.ref("active_shakers");
      const snapshot = await shakersRef.once("value");

      if (!snapshot.exists()) {
        return null;
      }

      const deletePromises: Promise<void>[] = [];

      snapshot.forEach((geohashSnapshot) => {
        geohashSnapshot.forEach((userSnapshot) => {
          const shakerData = userSnapshot.val();

          // Check if shaker is stale (no activity for more than threshold)
          if (now - shakerData.timestamp > staleThreshold) {
            deletePromises.push(userSnapshot.ref.remove());
            cleanedCount++;
          }
        });
      });

      await Promise.all(deletePromises);

      if (cleanedCount > 0) {
        functions.logger.info(`Cleaned up ${cleanedCount} stale shakers`);
      }

      return null;

    } catch (error) {
      functions.logger.error("Error cleaning up stale shakers", { error });
      return null;
    }
  });

/**
 * Scheduled function: Update user statistics
 * Runs daily to update user match statistics
 */
export const updateUserStats = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    try {
      const batch = db.batch();
      let updatedUsers = 0;

      // Get all users
      const users = await db.collection("users").get();

      for (const userDoc of users.docs) {
        const userId = userDoc.id;

        // Count user's matches
        const matchesQuery = await db
          .collection("matches")
          .where("participants", "array-contains", userId)
          .get();

        const stats = {
          totalMatches: matchesQuery.size,
          revealedMatches: matchesQuery.docs.filter(
            doc => doc.data().status === "revealed"
          ).length,
          archivedMatches: matchesQuery.docs.filter(
            doc => doc.data().status === "archived"
          ).length,
        };

        // Update user stats
        batch.update(userDoc.ref, {
          stats,
          statsUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        updatedUsers++;

        // Commit in batches of 500 (Firestore limit)
        if (updatedUsers % 500 === 0) {
          await batch.commit();
        }
      }

      // Commit remaining updates
      if (updatedUsers % 500 !== 0) {
        await batch.commit();
      }

      functions.logger.info(`Updated stats for ${updatedUsers} users`);
      return null;

    } catch (error) {
      functions.logger.error("Error updating user stats", { error });
      return null;
    }
  });

/**
 * HTTP Cloud Function: Manual cleanup (for admin use)
 */
export const manualCleanup = functions.https.onCall(async (data, context) => {
  // Verify admin access (you should implement proper admin verification)
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required");
  }

  // Additional admin verification would go here
  // For now, assuming any authenticated user can call this for demo purposes

  try {
    const { type, days } = data as { type: string; days?: number };
    const results: any = {};

    switch (type) {
    case "expired_matches": {
      // Manually trigger match archival
      const now = new Date();
      const expiredMatches = await db
        .collection("matches")
        .where("status", "==", "anonymous")
        .where("anonymousPhaseEnds", "<=", now)
        .get();

      results.expiredMatches = expiredMatches.size;
      break;
    }

    case "old_data": {
      // Manually trigger old data cleanup
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - (days || 30));

      const oldMatches = await db
        .collection("matches")
        .where("status", "==", "archived")
        .where("archivedAt", "<=", cutoff)
        .get();

      results.oldMatches = oldMatches.size;
      break;
    }

    case "stale_shakers": {
      // Manually trigger stale shaker cleanup
      const shakersSnapshot = await realtimeDb.ref("active_shakers").once("value");
      let staleCount = 0;

      if (shakersSnapshot.exists()) {
        const nowTimestamp = Date.now();
        shakersSnapshot.forEach((geohash) => {
          geohash.forEach((user) => {
            const userData = user.val();
            if (nowTimestamp - userData.timestamp > 60000) {
              staleCount++;
            }
          });
        });
      }

      results.staleShakers = staleCount;
      break;
    }

    default:
      throw new functions.https.HttpsError("invalid-argument", "Invalid cleanup type");
    }

    return {
      success: true,
      type,
      results,
      timestamp: new Date().toISOString(),
    };

  } catch (error) {
    functions.logger.error("Error in manual cleanup", { error });
    throw new functions.https.HttpsError("internal", "Cleanup failed");
  }
});