import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blind_shake/src/features/auth/data/models/auth_state.dart';
import 'package:blind_shake/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:blind_shake/src/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:blind_shake/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:blind_shake/src/features/matching/presentation/screens/home_screen.dart';
import 'package:blind_shake/src/features/matching/presentation/screens/matching_screen.dart';
import 'package:blind_shake/src/features/chat/presentation/screens/anonymous_chat_screen.dart';
import 'package:blind_shake/src/features/profile/presentation/screens/settings_screen.dart';

// Route paths
abstract class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String matching = '/matching';
  static const String chat = '/chat';
  static const String settings = '/settings';
}

// Global navigation key
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to handle redirects
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final currentLocation = state.uri.path;
      final isSignInRoute = currentLocation == AppRoutes.signIn;
      final isSplashRoute = currentLocation == AppRoutes.splash;

      // Handle auth state redirects
      switch (authState.status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          // Stay on splash screen while loading
          return isSplashRoute ? null : AppRoutes.splash;

        case AuthStatus.authenticated:
          // Redirect to home if on auth screens
          if (isSignInRoute || isSplashRoute) {
            return AppRoutes.home;
          }
          return null; // Stay on current route

        case AuthStatus.unauthenticated:
        case AuthStatus.error:
          // Redirect to sign in if not authenticated
          if (!isSignInRoute && !isSplashRoute) {
            return AppRoutes.signIn;
          }
          return isSignInRoute ? null : AppRoutes.signIn;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'matching',
            name: 'matching',
            builder: (context, state) => const MatchingScreen(),
          ),
          GoRoute(
            path: 'chat',
            name: 'chat',
            builder: (context, state) {
              final matchId = state.uri.queryParameters['matchId'];
              return AnonymousChatScreen(matchId: matchId);
            },
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Aranan sayfa: ${state.uri.path}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Extension for easier navigation
extension GoRouterExtension on GoRouter {
  void clearStackAndPush(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
}

// Navigation helpers
abstract class AppNavigation {
  static void toHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void toSignIn(BuildContext context) {
    context.go(AppRoutes.signIn);
  }

  static void toMatching(BuildContext context) {
    context.push('${AppRoutes.home}/matching');
  }

  static void toChat(BuildContext context, String matchId) {
    context.push('${AppRoutes.home}/chat?matchId=$matchId');
  }

  static void toSettings(BuildContext context) {
    context.push('${AppRoutes.home}/settings');
  }

  static void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}