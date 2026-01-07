import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Import feature modules
export * from "./matching";
export * from "./chat";
export * from "./cleanup";