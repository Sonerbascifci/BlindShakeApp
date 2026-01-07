// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  photoURL: json['photoURL'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoURL': instance.photoURL,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt.toIso8601String(),
  'isActive': instance.isActive,
};
