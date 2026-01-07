# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**BlindShake** is an anonymous matching and chat app where users shake their phones to match with nearby people, chat anonymously for 15 minutes, then decide whether to reveal identities and continue.

## Current State

The project is in **active migration** from Firebase to Supabase:

- ✅ Basic Flutter app structure with Material 3 dark theme
- ✅ Theme system (colors, typography) fully implemented
- ✅ Complete authentication system with Google Sign-In
- ✅ Riverpod state management with code generation (@riverpod annotations)
- ✅ go_router with auth-aware navigation and redirects
- ✅ Repository pattern implemented for auth data layer
- ✅ Feature-based architecture with auth module fully functional
- ✅ Shake detection service using sensors_plus accelerometer
- ✅ Location service with privacy-aware coordinate handling
- ✅ Anonymous chat system with 15-minute timer logic
- ✅ **UI integration with matching services** - COMPLETED January 7, 2026
- ✅ **Comprehensive location permission handling** - COMPLETED January 7, 2026
- ✅ **Real-time chat implementation** - COMPLETED January 7, 2026
- 🚧 **SUPABASE MIGRATION IN PROGRESS** - Started January 7, 2026

### Backend Status (Migration)
- ✅ **Supabase migrations created** - PostGIS schema, RLS policies, pg_cron jobs
- ✅ **Edge Functions created** - start-shaking, stop-shaking, request-reveal, decline-reveal
- ✅ **Flutter Supabase services** - Auth, matching, chat services with Riverpod providers
- ⏳ **Pending**: Update pubspec.yaml, main.dart, deploy to Supabase project

## Architecture

The codebase follows a feature-based architecture:

```
lib/
├── main.dart                # Entry point (update for Supabase)
└── src/
    ├── app/                 # App-level config
    │   ├── router.dart      # ✅ go_router with auth-aware navigation
    │   └── theme/           # ✅ AppTheme, AppColors, AppTypography
    ├── core/
    │   ├── services/        # ✅ Location, shake detection, app setup
    │   └── supabase/        # 🆕 Supabase providers and config
    ├── features/
    │   ├── auth/            # Auth with Google Sign-In
    │   │   ├── data/        # 🆕 supabase_auth_service.dart, user_model.dart
    │   │   └── presentation/
    │   ├── matching/        # 🆕 supabase_matching_service.dart
    │   ├── chat/            # 🆕 supabase_chat_service.dart
    │   └── profile/
    └── shared/
        └── widgets/         # ✅ ShakeButton, AnonymousAvatar, TimerWidget

supabase/                    # 🆕 Supabase backend (replaces functions/)
├── migrations/              # SQL migrations (001-004)
├── functions/               # Edge Functions (TypeScript/Deno)
│   ├── start-shaking/
│   ├── stop-shaking/
│   ├── request-reveal/
│   └── decline-reveal/
├── MIGRATION_GUIDE.md       # Step-by-step migration instructions
└── .env.example             # Environment variable template

```

**Implemented patterns**:
- ✅ Repository pattern for auth data layer
- ✅ Riverpod with code generation (`@riverpod` annotations)
- ✅ Feature-first organization (data/domain/presentation per feature)
- ✅ Stream-based auth state management
- ✅ Error handling and loading states

## Development Commands

```bash
# Run app
flutter run

# Get dependencies (run after pubspec.yaml changes)
flutter pub get

# Code generation (for Riverpod when implemented)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code gen
dart run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Build APK
flutter build apk --release
```

## Key Dependencies

| Package | Purpose | Status |
|---------|---------|--------|
| `flutter_riverpod` + `riverpod_annotation` | State management | ✅ Fully implemented with code gen |
| `go_router` | Declarative routing | ✅ Implemented with auth redirects |
| `supabase_flutter` | Backend services | 🆕 Migration ready (replaces `firebase_*`) |
| `geolocator` | Location services | ✅ Implemented with privacy controls |
| `sensors_plus` | Accelerometer for shake detection | ✅ Implemented with debouncing |
| `google_sign_in` | Authentication | ✅ Works with Supabase OAuth |

## Supabase Schema (Migrated)

```sql
-- PostgreSQL with PostGIS
users              -- User profiles with stats
matches            -- Active matches with PostGIS geometry
messages           -- Chat messages (RLS enforced)
active_shakers     -- Users shaking (PostGIS POINT, auto-cleanup)

-- Key Features:
-- ST_DWithin() for proximity queries (replaces geohash)
-- pg_cron for scheduled cleanup jobs
-- Real-time subscriptions for messages/matches
```

## Recent Development (January 7, 2026)

**Major Milestones:**

1. **UI Integration with Matching Services** (3 hours)
   - Real accelerometer-based shake detection
   - Comprehensive location permission management
   - Full integration with backend matching algorithm

2. **Real-time Chat Implementation** (2 hours)
   - Service layer with real-time message streaming
   - Timer countdown with automatic decision modal
   - Reveal/decline functionality

3. **Supabase Migration Started** (in progress)
   - Created PostgreSQL schema with PostGIS
   - Created Edge Functions (Deno/TypeScript)
   - Created Flutter Supabase services

## Critical Implementation Notes

1. 🚧 **Supabase Migration**: See `supabase/MIGRATION_GUIDE.md` for setup steps
2. ✅ **Location Permissions**: Completed with comprehensive runtime handling
3. ✅ **Shake Detection**: Implemented with `sensors_plus` and debouncing
4. **Anonymous Chat**: First 15 minutes must hide all PII
5. **PostGIS Strategy**: Use `ST_DWithin()` for accurate proximity queries
6. **Real-time**: Use Supabase Realtime for messages and match status
7. **Edge Functions**: Server-side matching logic in TypeScript/Deno

## Security Constraints

- Never log user location coordinates
- Never commit Supabase credentials or API keys
- Always validate user input (RLS + Edge Functions)
- Use Row Level Security (RLS) for all tables

