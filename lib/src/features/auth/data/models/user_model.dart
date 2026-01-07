/// BlindShake User Model
/// 
/// Data model for user profile information
/// Used across auth and profile features

class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? currentMatchId;
  final DateTime? lastMatchAt;
  final Map<String, dynamic>? stats;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.currentMatchId,
    this.lastMatchAt,
    this.stats,
  });

  /// Create UserModel from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      currentMatchId: json['current_match_id'] as String?,
      lastMatchAt: json['last_match_at'] != null
          ? DateTime.parse(json['last_match_at'] as String)
          : null,
      stats: json['stats'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (currentMatchId != null) 'current_match_id': currentMatchId,
      if (lastMatchAt != null) 'last_match_at': lastMatchAt!.toIso8601String(),
      if (stats != null) 'stats': stats,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? currentMatchId,
    DateTime? lastMatchAt,
    Map<String, dynamic>? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      currentMatchId: currentMatchId ?? this.currentMatchId,
      lastMatchAt: lastMatchAt ?? this.lastMatchAt,
      stats: stats ?? this.stats,
    );
  }

  /// Get total matches count from stats
  int get totalMatches => stats?['totalMatches'] as int? ?? 0;

  /// Get revealed matches count from stats
  int get revealedMatches => stats?['revealedMatches'] as int? ?? 0;

  /// Get archived matches count from stats
  int get archivedMatches => stats?['archivedMatches'] as int? ?? 0;

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email)';
  }
}
