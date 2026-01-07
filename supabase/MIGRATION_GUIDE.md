# BlindShake Supabase Migration Guide

## Overview

This guide explains how to complete the migration from Firebase to Supabase.

## Prerequisites

1. **Supabase Account**: Create a free account at [supabase.com](https://supabase.com)
2. **Supabase CLI** (optional but recommended):
   ```bash
   npm install -g supabase
   ```

## Step 1: Create Supabase Project

1. Go to [app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in:
   - **Name**: `blindshake` (or your preferred name)
   - **Database Password**: Save this securely!
   - **Region**: Choose closest to your users (e.g., `eu-central-1` for Turkey)
4. Wait for project to be ready (~2 minutes)

## Step 2: Get Project Credentials

1. Go to Project Settings → API
2. Copy these values (you'll need them for Flutter):
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon key**: `eyJ...` (public, safe for client-side)
   - **service_role key**: `eyJ...` (secret, only for Edge Functions)

## Step 3: Run Database Migrations

Go to SQL Editor in Supabase Dashboard and run each file in order:

1. **001_initial_schema.sql** - Creates tables with PostGIS
2. **002_rls_policies.sql** - Sets up Row Level Security
3. **003_scheduled_jobs.sql** - Configures pg_cron cleanup jobs
4. **004_realtime_config.sql** - Enables realtime subscriptions

**Note**: For pg_cron (003), you need to enable it first:
- Go to Database → Extensions
- Search for "pg_cron" and enable it

## Step 4: Configure Google OAuth

1. Go to Authentication → Providers
2. Find "Google" and enable it
3. Add your Google OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console
4. Add redirect URLs in Google Console:
   - `https://xxxxx.supabase.co/auth/v1/callback`

## Step 5: Deploy Edge Functions

Using Supabase CLI:

```bash
cd supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Deploy all functions
supabase functions deploy start-shaking
supabase functions deploy stop-shaking
supabase functions deploy request-reveal
supabase functions deploy decline-reveal
```

## Step 6: Update Flutter App

### Update pubspec.yaml

Replace Firebase dependencies:

```yaml
dependencies:
  # Remove Firebase packages
  # firebase_core: ^3.8.1
  # firebase_auth: ^5.3.4
  # cloud_firestore: ^5.6.0
  # firebase_database: ^11.2.0
  # firebase_storage: ^12.3.7
  # firebase_messaging: ^15.1.6
  # cloud_functions: ^5.2.1
  
  # Add Supabase
  supabase_flutter: ^2.3.0
```

Run:
```bash
flutter pub get
```

### Update main.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const ProviderScope(child: BlindShakeApp()));
}
```

### Update Providers

The new Supabase providers are in:
- `lib/src/core/supabase/supabase_providers.dart`
- `lib/src/core/supabase/supabase_service_providers.dart`

Update your existing screens to use the new providers.

## Step 7: Test the Migration

1. Run the app: `flutter run`
2. Test Google Sign-In
3. Test shaking and matching
4. Test chat messaging
5. Test reveal/decline flow

## Environment Variables

For production, use environment variables:

```dart
// lib/src/core/config/supabase_config.dart
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_DEV_URL',
  );
  
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_DEV_KEY',
  );
}
```

Build with:
```bash
flutter build apk --dart-define=SUPABASE_URL=https://prod.supabase.co --dart-define=SUPABASE_ANON_KEY=your-prod-key
```

## Rollback Plan

If issues arise:
1. Firebase project is still available
2. Re-add Firebase dependencies to `pubspec.yaml`
3. Update `main.dart` back to Firebase initialization
4. Switch providers back to Firebase implementations

## Support

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [PostGIS Documentation](https://postgis.net/documentation/)
