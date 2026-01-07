/// BlindShake Supabase Providers
/// 
/// Riverpod providers for Supabase services
/// Centralizes dependency injection for auth, matching, and chat

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blind_shake/src/features/auth/data/services/supabase_auth_service.dart';
import 'package:blind_shake/src/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:blind_shake/src/features/matching/data/services/supabase_matching_service.dart';
import 'package:blind_shake/src/features/chat/data/services/supabase_chat_service.dart';

// =============================================================================
// CORE SUPABASE
// =============================================================================

/// Provider for the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for current auth state stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Provider for current user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// =============================================================================
// AUTH
// =============================================================================

/// Provider for Supabase Auth Service
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthService(client: client);
});

/// Provider for Supabase Auth Repository
final supabaseAuthRepositoryProvider = Provider<SupabaseAuthRepository>((ref) {
  final authService = ref.watch(supabaseAuthServiceProvider);
  return SupabaseAuthRepository(authService: authService);
});

// =============================================================================
// MATCHING
// =============================================================================

/// Provider for Supabase Matching Service
final supabaseMatchingServiceProvider = Provider<SupabaseMatchingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchingService(client: client);
});

/// Provider for current match (if any)
final currentMatchProvider = FutureProvider<Match?>((ref) async {
  final service = ref.watch(supabaseMatchingServiceProvider);
  return await service.getCurrentMatch();
});

/// Provider for watching a specific match
final watchMatchProvider = StreamProvider.family<Match?, String>((ref, matchId) {
  final service = ref.watch(supabaseMatchingServiceProvider);
  return service.watchMatch(matchId);
});

// =============================================================================
// CHAT
// =============================================================================

/// Provider for Supabase Chat Service
final supabaseChatServiceProvider = Provider<SupabaseChatService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatService(client: client);
});

/// Provider for watching messages in a match
final messagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, matchId) {
  final service = ref.watch(supabaseChatServiceProvider);
  return service.watchMessages(matchId);
});

/// Provider for watching match status (for reveal timer)
final matchStatusProvider = StreamProvider.family<MatchStatus, String>((ref, matchId) {
  final service = ref.watch(supabaseChatServiceProvider);
  return service.watchMatchStatus(matchId);
});
