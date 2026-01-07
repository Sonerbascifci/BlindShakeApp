import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, createdAt: $createdAt, lastLoginAt: $lastLoginAt, isActive: $isActive)';
  }
}