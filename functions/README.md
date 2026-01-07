# BlindShake Cloud Functions

This directory contains Firebase Cloud Functions for the BlindShake anonymous matching app.

## Architecture

The Cloud Functions are organized into feature modules:

- **`src/matching/`** - Real-time matching algorithm and geohash-based proximity queries
- **`src/chat/`** - Anonymous chat message handling and reveal logic
- **`src/cleanup/`** - Scheduled cleanup of expired data and matches
- **`src/shared/`** - Common utilities like geohash calculations

## Functions Overview

### Matching Functions

- **`startShaking`** (HTTPS Callable) - Add user to active shakers pool
- **`stopShaking`** (HTTPS Callable) - Remove user from shaking pool
- **`cleanupExpiredShakers`** (Scheduled) - Remove stale shakers every minute

### Chat Functions

- **`sendMessage`** (HTTPS Callable) - Send message in anonymous chat
- **`requestReveal`** (HTTPS Callable) - Request identity reveal after 15min
- **`declineReveal`** (HTTPS Callable) - Decline reveal and archive match
- **`onMatchUpdate`** (Firestore Trigger) - Handle match status changes

### Cleanup Functions

- **`autoArchiveExpiredMatches`** (Scheduled) - Archive old anonymous matches
- **`cleanupOldData`** (Scheduled) - Delete archived data older than 30 days
- **`cleanupStaleShakers`** (Scheduled) - Remove inactive shakers
- **`updateUserStats`** (Scheduled) - Update user match statistics
- **`manualCleanup`** (HTTPS Callable) - Admin cleanup operations

## Data Flow

1. **Shaking Phase**: User shakes phone → `startShaking` → adds to Realtime DB
2. **Matching**: Function finds nearby shakers → creates Firestore match
3. **Anonymous Chat**: 15-minute timer → messages via `sendMessage`
4. **Reveal Phase**: Users can request reveal → `requestReveal`/`declineReveal`
5. **Cleanup**: Scheduled functions clean expired data

## Database Schema

### Firestore Collections

```
users/{userId}                      # User profiles
matches/{matchId}                   # Match documents
  └── messages/{messageId}          # Chat messages subcollection
archived_chats/{chatId}             # Post-reveal conversations
```

### Realtime Database

```
active_shakers/{geoHash}/{userId}   # Ephemeral shaker data (TTL: 30s)
```

## Setup & Deployment

### Prerequisites

1. Firebase CLI installed: `npm install -g firebase-tools`
2. Firebase project with Blaze plan (for Cloud Functions)
3. Node.js 18+ installed

### Installation

```bash
cd functions
npm install
```

### Local Development

```bash
# Start Firebase emulators
npm run serve

# Build and watch for changes
npm run build:watch

# Run linting
npm run lint
```

### Deployment

```bash
# Build functions
npm run build

# Deploy all functions
npm run deploy

# Deploy specific function
firebase deploy --only functions:startShaking
```

### Environment Setup

The functions use Firebase Admin SDK which automatically configures with your Firebase project. No additional environment variables are required for basic functionality.

## Security

### Authentication

- All callable functions verify user authentication via `context.auth.uid`
- Functions check user participation in matches before operations
- Input validation on all parameters

### Data Privacy

- Location coordinates are stored with reduced precision (4 decimal places)
- Anonymous chat phase hides all PII for 15 minutes
- Automatic cleanup of expired and old data

### Rate Limiting

Consider implementing rate limiting for production:

```typescript
// Example rate limiting (not implemented yet)
const rateLimiter = new RateLimiter({
  max: 10, // 10 requests
  windowMs: 60000, // per minute
});
```

## Monitoring

### Logging

Functions use structured logging:

```typescript
functions.logger.info("Event description", {
  userId: "user123",
  matchId: "match456",
  customData: "value"
});
```

### Error Handling

All functions implement comprehensive error handling:

- Try-catch blocks around all operations
- Structured error logging with context
- Appropriate HTTP error codes for client
- Graceful degradation when possible

## Testing

### Unit Tests

```bash
npm test
```

### Integration Tests

Test with Firebase emulators:

```bash
npm run serve
# Run integration tests against emulators
```

### Load Testing

For production, consider load testing the matching algorithm with multiple concurrent shakers.

## Performance Optimization

### Cold Start Mitigation

- Keep functions warm with scheduled pings (not implemented)
- Minimize dependencies and imports
- Use connection pooling for database operations

### Database Optimization

- Compound indexes for Firestore queries
- Geohash indexing for proximity queries
- Efficient batch operations for cleanup

### Memory Usage

Current functions are optimized for 512MB memory. Monitor usage and adjust if needed:

```bash
firebase functions:config:set memory=1GB
```

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure Firebase Admin SDK has proper IAM roles
2. **Timeout Errors**: Increase function timeout for heavy operations
3. **Memory Errors**: Monitor function memory usage and optimize
4. **Geohash Issues**: Validate location coordinates before processing

### Debug Logs

Enable debug logging:

```bash
firebase functions:log --only startShaking
```

## Contributing

When adding new functions:

1. Follow the existing module structure
2. Add comprehensive error handling
3. Include structured logging
4. Update this README with new functions
5. Add appropriate tests

## License

This code is part of the BlindShake project and follows the project's licensing terms.