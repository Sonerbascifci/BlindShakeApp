# Authentication Feature

This directory contains the complete authentication infrastructure for the BlindShake app, including Google Sign-In integration with Firebase Auth.

## Architecture

The authentication feature follows a clean architecture pattern with clear separation of concerns:

```
auth/
├── data/
│   ├── models/           # Data models (AppUser, AuthState)
│   ├── services/         # Firebase Auth Service
│   └── repositories/     # Auth Repository interface & implementation
├── presentation/
│   ├── providers/        # Riverpod providers for state management
│   ├── screens/          # UI screens (SignIn, Splash)
│   └── widgets/          # Reusable auth widgets
└── auth.dart            # Feature exports
```

## Key Components

### Data Layer

1. **AppUser Model** (`data/models/app_user.dart`)
   - Represents user data with JSON serialization
   - Contains uid, email, displayName, photoURL, timestamps

2. **AuthState Model** (`data/models/auth_state.dart`)
   - Manages authentication states: initial, loading, authenticated, unauthenticated, error
   - Provides convenient getters for state checking

3. **FirebaseAuthService** (`data/services/firebase_auth_service.dart`)
   - Handles Firebase Authentication operations
   - Google Sign-In integration
   - User data persistence in Firestore
   - Comprehensive error handling

4. **AuthRepository** (`data/repositories/auth_repository.dart`)
   - Abstract interface for auth operations
   - Implementation using FirebaseAuthService
   - Provides clean API for presentation layer

### Presentation Layer

1. **Auth Providers** (`presentation/providers/auth_providers.dart`)
   - Riverpod providers for dependency injection
   - AuthNotifier for state management
   - Stream providers for real-time auth state

2. **SignInScreen** (`presentation/screens/sign_in_screen.dart`)
   - User-friendly sign-in interface
   - Google Sign-In button integration
   - Error handling with dialogs

3. **SplashScreen** (`presentation/screens/splash_screen.dart`)
   - Loading screen with animations
   - Shown during app initialization

4. **GoogleSignInButton** (`presentation/widgets/google_sign_in_button.dart`)
   - Custom Google Sign-In button
   - Loading states and error handling

## Usage

### Integration with Router

The auth system is fully integrated with go_router for automatic navigation:

```dart
// Router automatically redirects based on auth state
// - Unauthenticated users → SignInScreen
// - Authenticated users → HomeScreen
// - Loading state → SplashScreen
```

### Using Auth State in Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user
    final user = ref.watch(currentUserProvider);

    // Watch auth state
    final authState = ref.watch(authNotifierProvider);

    // Perform auth operations
    return ElevatedButton(
      onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
      child: Text('Sign In'),
    );
  }
}
```

## Firebase Configuration

### Firestore Structure

```
users/{userId} {
  uid: string
  email: string
  displayName: string
  photoURL: string?
  createdAt: timestamp
  lastLoginAt: timestamp
  isActive: boolean
}
```

### Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling

The auth system provides comprehensive error handling:

- Firebase Auth errors are mapped to user-friendly messages
- Network errors are handled gracefully
- State management prevents invalid states
- UI shows loading states and error dialogs

## Dependencies

- `firebase_auth`: Firebase Authentication
- `google_sign_in`: Google Sign-In
- `cloud_firestore`: User data storage
- `flutter_riverpod`: State management
- `go_router`: Navigation

## Code Generation

Run the following command when making changes to providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

The auth system is designed to be testable:

- Repository pattern allows easy mocking
- Riverpod providers can be overridden in tests
- Firebase Auth can be mocked using `fake_cloud_firestore`