---
description: Set up Firebase project and configure Flutter
---

# Setup Firebase

Complete Firebase setup for BlindShake project.

## Prerequisites

- Firebase CLI installed (`npm install -g firebase-tools`)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- Google account with Firebase access

## Steps

### 1. Login to Firebase

```bash
firebase login
```

### 2. Create Firebase Project

Go to [Firebase Console](https://console.firebase.google.com) and create a new project:
- Project name: `blindshake`
- Enable Google Analytics (optional)

### 3. Configure FlutterFire

// turbo
```bash
flutterfire configure --project=blindshake
```

This will:
- Create `lib/firebase_options.dart`
- Configure Android (`google-services.json`)
- Configure iOS (`GoogleService-Info.plist`)

### 4. Enable Firebase Services

In Firebase Console, enable:

**Authentication:**
- [ ] Email/Password
- [ ] Google Sign-in

**Firestore Database:**
- [ ] Create database in production mode
- [ ] Choose `europe-west1` or nearest region

**Realtime Database:**
- [ ] Create database
- [ ] Choose same region as Firestore

**Cloud Storage:**
- [ ] Get started
- [ ] Choose same region

**Cloud Messaging:**
- [ ] Automatically enabled

### 5. Initialize Cloud Functions

```bash
cd functions
npm init -y
npm install firebase-functions firebase-admin typescript
```

### 6. Deploy Security Rules

```bash
firebase deploy --only firestore:rules
firebase deploy --only database:rules
firebase deploy --only storage:rules
```

## Verification

// turbo
```bash
flutter run
```

Check console for:
```
I/flutter: Firebase initialized successfully
```

## Common Issues

**Issue:** `firebase_options.dart` not found
**Solution:** Run `flutterfire configure` again

**Issue:** Google Sign-in not working on Android
**Solution:** Add SHA-1 fingerprint in Firebase Console
```bash
cd android && ./gradlew signingReport
```

**Issue:** iOS build fails with Firebase
**Solution:** Run `cd ios && pod install --repo-update`
