import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  GeoPoint,
  getGeoHash,
  getGeoHashPrecision,
  distanceBetween,
  isValidLocation
} from "../shared/geohash";

const db = admin.firestore();
const realtimeDb = admin.database();

interface ActiveShaker {
  userId: string;
  location: GeoPoint;
  timestamp: number;
  geohash: string;
  displayName?: string;
  photoURL?: string;
  distance?: number;
}

/**
 * HTTP Cloud Function: Start shaking and enter matching pool
 */
export const startShaking = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { location } = data as { location: GeoPoint };

  // Validate input
  if (!location || !isValidLocation(location)) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid location provided");
  }

  const userId = context.auth.uid;
  const timestamp = Date.now();

  try {
    // Get user profile for anonymous display info
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User profile not found");
    }

    const userData = userDoc.data()!;
    const precision = getGeoHashPrecision(50); // Start with 50km radius
    const geohash = getGeoHash(location, precision);

    // Create active shaker data
    const shakerData: ActiveShaker = {
      userId,
      location,
      timestamp,
      geohash,
      displayName: userData.displayName,
      photoURL: userData.photoURL,
    };

    // Add to active shakers in Realtime Database (ephemeral data)
    const shakerRef = realtimeDb.ref(`active_shakers/${geohash}/${userId}`);
    await shakerRef.set({
      ...shakerData,
      // Don't store exact coordinates in logs
      location: {
        latitude: Number(location.latitude.toFixed(4)), // Reduced precision for privacy
        longitude: Number(location.longitude.toFixed(4)),
      },
    });

    // Set TTL for automatic cleanup (30 seconds)
    await shakerRef.child("expires_at").set(timestamp + 30000);

    // Start matching process
    const matchResult = await findMatch(shakerData);

    functions.logger.info("User started shaking", {
      userId,
      geohash,
      hasMatch: !!matchResult,
    });

    return {
      success: true,
      shakerRef: shakerRef.key,
      geohash,
      match: matchResult,
    };

  } catch (error) {
    functions.logger.error("Error starting shake", { userId, error });
    throw new functions.https.HttpsError("internal", "Failed to start shaking");
  }
});

/**
 * HTTP Cloud Function: Stop shaking and remove from matching pool
 */
export const stopShaking = functions.https.onCall(async (data, context) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { geohash } = data as { geohash: string };
  const userId = context.auth.uid;

  try {
    // Remove from active shakers
    await realtimeDb.ref(`active_shakers/${geohash}/${userId}`).remove();

    functions.logger.info("User stopped shaking", { userId, geohash });

    return { success: true };
  } catch (error) {
    functions.logger.error("Error stopping shake", { userId, error });
    throw new functions.https.HttpsError("internal", "Failed to stop shaking");
  }
});

/**
 * Find potential matches for a shaking user
 */
async function findMatch(currentShaker: ActiveShaker): Promise<any | null> {
  try {
    const { location, userId, timestamp } = currentShaker;
    const searchRadiusKm = 1000; // Maximum radius for BlindShake

    // Check multiple geohash precisions for broader search
    const precisions = [6, 5, 4]; // Start precise, expand if no matches

    for (const precision of precisions) {
      const searchGeohash = getGeoHash(location, precision);

      // Query active shakers in this geohash
      const shakersSnapshot = await realtimeDb
        .ref(`active_shakers/${searchGeohash}`)
        .once("value");

      if (!shakersSnapshot.exists()) {
        continue; // Try next precision level
      }

      const potentialMatches: ActiveShaker[] = [];
      shakersSnapshot.forEach((child) => {
        const shaker = child.val() as ActiveShaker;

        // Skip self and expired entries
        if (shaker.userId === userId || timestamp - shaker.timestamp > 30000) {
          return;
        }

        // Check distance constraint
        const distance = distanceBetween(location, shaker.location);
        if (distance <= searchRadiusKm) {
          potentialMatches.push({
            ...shaker,
            distance,
          });
        }
      });

      if (potentialMatches.length > 0) {
        // Sort by distance and timestamp (newer matches preferred)
        potentialMatches.sort((a, b) => {
          const distanceDiff = (a.distance || 0) - (b.distance || 0);
          if (Math.abs(distanceDiff) < 1) {
            // If distances are very close, prefer newer timestamp
            return (b.timestamp || 0) - (a.timestamp || 0);
          }
          return distanceDiff;
        });

        // Try to create match with closest user
        const matchedShaker = potentialMatches[0];
        const match = await createMatch(currentShaker, matchedShaker);

        if (match) {
          return match;
        }
      }
    }

    return null; // No match found
  } catch (error) {
    functions.logger.error("Error finding match", {
      userId: currentShaker.userId,
      error
    });
    return null;
  }
}

/**
 * Create a match between two users
 */
async function createMatch(user1: ActiveShaker, user2: ActiveShaker): Promise<any | null> {
  const batch = db.batch();

  try {
    // Generate match ID
    const matchId = `match_${user1.userId}_${user2.userId}_${Date.now()}`;
    const matchRef = db.collection("matches").doc(matchId);

    // Create match document
    const matchData = {
      id: matchId,
      participants: [user1.userId, user2.userId],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "anonymous", // anonymous -> revealed -> archived
      anonymousPhaseEnds: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes
      participantInfo: {
        [user1.userId]: {
          location: {
            latitude: Number(user1.location.latitude.toFixed(4)),
            longitude: Number(user1.location.longitude.toFixed(4)),
          },
          joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        [user2.userId]: {
          location: {
            latitude: Number(user2.location.latitude.toFixed(4)),
            longitude: Number(user2.location.longitude.toFixed(4)),
          },
          joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
    };

    batch.set(matchRef, matchData);

    // Update user profiles with current match
    batch.update(db.collection("users").doc(user1.userId), {
      currentMatchId: matchId,
      lastMatchAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    batch.update(db.collection("users").doc(user2.userId), {
      currentMatchId: matchId,
      lastMatchAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Remove both users from active shakers
    await Promise.all([
      realtimeDb.ref(`active_shakers/${user1.geohash}/${user1.userId}`).remove(),
      realtimeDb.ref(`active_shakers/${user2.geohash}/${user2.userId}`).remove(),
    ]);

    functions.logger.info("Match created successfully", {
      matchId,
      user1: user1.userId,
      user2: user2.userId
    });

    return {
      matchId,
      otherUser: {
        id: user2.userId,
        // During anonymous phase, don't reveal identity
        displayName: "Anonymous",
        photoURL: null,
      },
      anonymousPhaseEnds: matchData.anonymousPhaseEnds,
    };

  } catch (error) {
    functions.logger.error("Error creating match", {
      user1: user1.userId,
      user2: user2.userId,
      error
    });
    return null;
  }
}

/**
 * Realtime Database trigger: Cleanup expired active shakers
 */
export const cleanupExpiredShakers = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async () => {
    try {
      const now = Date.now();
      const shakersRef = realtimeDb.ref("active_shakers");
      const snapshot = await shakersRef.once("value");

      if (!snapshot.exists()) {
        return null;
      }

      const expiredRefs: Promise<void>[] = [];

      snapshot.forEach((geohashSnapshot) => {
        geohashSnapshot.forEach((userSnapshot) => {
          const shaker = userSnapshot.val() as ActiveShaker;
          if (now - shaker.timestamp > 30000) { // 30 seconds timeout
            expiredRefs.push(userSnapshot.ref.remove());
          }
        });
      });

      await Promise.all(expiredRefs);

      functions.logger.info(`Cleaned up ${expiredRefs.length} expired shakers`);
      return null;
    } catch (error) {
      functions.logger.error("Error cleaning up expired shakers", { error });
      return null;
    }
  });