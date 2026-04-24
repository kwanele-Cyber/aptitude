import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/models/location_model.dart';

enum UserRole { user, admin }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final List<SkillModel> offeredSkills;
  final List<SkillModel> desiredSkills;
  final LocationModel? location;
  final Map<String, dynamic> availability; // Simplified for initial version
  final double trustScore;
  final DateTime createdAt;
  final UserRole role;
  final bool isSuspended;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.offeredSkills,
    required this.desiredSkills,
    this.location,
    required this.availability,
    required this.trustScore,
    required this.createdAt,
    this.role = UserRole.user,
    this.isSuspended = false,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    List<SkillModel>? offeredSkills,
    List<SkillModel>? desiredSkills,
    LocationModel? location,
    Map<String, dynamic>? availability,
    double? trustScore,
    DateTime? createdAt,
    UserRole? role,
    bool? isSuspended,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      offeredSkills: offeredSkills ?? this.offeredSkills,
      desiredSkills: desiredSkills ?? this.desiredSkills,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      trustScore: trustScore ?? this.trustScore,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'offeredSkills': offeredSkills.map((s) => s.toJson()).toList(),
      'desiredSkills': desiredSkills.map((s) => s.toJson()).toList(),
      'location': location?.toJson(),
      'availability': availability,
      'trustScore': trustScore,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name,
      'isSuspended': isSuspended,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      offeredSkills: (json['offeredSkills'] as List<dynamic>?)
              ?.map((e) => SkillModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      desiredSkills: (json['desiredSkills'] as List<dynamic>?)
              ?.map((e) => SkillModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      location: json['location'] != null 
          ? LocationModel.fromJson(Map<String, dynamic>.from(json['location'] as Map)) 
          : null,
      availability: Map<String, dynamic>.from(json['availability'] as Map? ?? {}),
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      isSuspended: json['isSuspended'] as bool? ?? false,
    );
  }
}

