/// BlindShake Supabase Client Provider
/// 
/// Provides the Supabase client instance for dependency injection
/// Replaces Firebase Core initialization

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the current Supabase session (nullable)
final supabaseSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session);
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(supabaseSessionProvider);
  return session.when(
    data: (session) => session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for current user ID (nullable)
final currentUserIdProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser?.id;
});
