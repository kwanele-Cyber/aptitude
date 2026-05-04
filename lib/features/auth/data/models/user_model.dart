import 'package:myapp/features/auth/data/models/address_model.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.title,
    super.photoURL,
    super.skills,
    super.interests,
    super.bio,
    super.location,
    super.phone,
    super.profileComplete,
    super.twoFactorEnabled,
    super.twoFactorPin,
    super.trustScore,
    super.isVerified,
    super.role,
    super.updatedAt,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      photoURL: json['photoURL'] as String? ?? '',
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      interests:
          (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bio: json['bio'] as String? ?? '',
      location: json['location'] is Map
          ? AddressModel.fromJson(json['location'] as Map<String, dynamic>)
          : const AddressModel.empty(),
      phone: json['phone'] as String?,
      profileComplete: json['profileComplete'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      twoFactorPin: json['twoFactorPin'] as String?,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
      role: (json['role'] as String? ?? 'member').toLowerCase(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'title': title,
      'photoURL': photoURL,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      if (location is AddressModel)
        'location': (location as AddressModel).toJson(),
      'phone': phone,
      'profileComplete': profileComplete,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorPin': twoFactorPin,
      'trustScore': trustScore,
      'isVerified': isVerified,
      'role': role,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
