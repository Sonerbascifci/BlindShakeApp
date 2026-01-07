---
description: Deploy Cloud Functions to Firebase
---

# Deploy Cloud Functions

Deploy TypeScript Cloud Functions to Firebase.

## Prerequisites

- Firebase Blaze plan (pay-as-you-go) enabled
- Functions code compiled successfully
- Firebase CLI logged in

## Directory Structure

```
functions/
├── src/
│   ├── index.ts          # Export all functions
│   ├── matching/
│   ├── chat/
│   ├── cleanup/
│   └── notifications/
├── lib/                   # Compiled JS (gitignored)
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

## Steps

### 1. Navigate to functions directory

```bash
cd functions
```

### 2. Install dependencies

// turbo
```bash
npm install
```

### 3. Build TypeScript

// turbo
```bash
npm run build
```

### 4. Test locally (optional)

```bash
firebase emulators:start --only functions
```

### 5. Deploy all functions

```bash
firebase deploy --only functions
```

### 6. Deploy specific function

```bash
firebase deploy --only functions:onShake
firebase deploy --only functions:revealMatch
```

## Function List

| Function | Trigger | Description |
|----------|---------|-------------|
| `onShake` | RTDB onCreate | Handle new shake events |
| `revealMatch` | Scheduled (1 min) | Reveal matches after 15 min |
| `archiveChat` | Firestore onUpdate | Archive declined chats |
| `cleanupExpiredShakes` | Scheduled (5 min) | Remove old shakers |
| `cleanupArchivedChats` | Scheduled (24 hours) | Delete expired archives |

## Logs

View function logs:
```bash
firebase functions:log

# Specific function
firebase functions:log --only onShake

# Follow mode
firebase functions:log -f
```

## Environment Variables

Set secrets:
```bash
firebase functions:secrets:set SECRET_NAME
```

Access in code:
```typescript
const secret = process.env.SECRET_NAME;
```

## Rollback

If deployment fails or causes issues:
```bash
firebase functions:delete onShake
# Then redeploy previous version
```

## Cost Monitoring

Check Firebase Console → Functions → Usage tab regularly.
Set budget alerts in Google Cloud Console.
