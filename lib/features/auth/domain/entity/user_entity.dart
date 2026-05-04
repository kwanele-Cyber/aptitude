import 'package:equatable/equatable.dart';
import 'package:myapp/features/auth/domain/entity/location_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String title;
  final String photoURL;
  final List<String> skills;
  final List<String> interests;
  final String bio;
  final LocationEntity location;
  final String? phone;
  final bool profileComplete;
  final bool twoFactorEnabled;
  final String? twoFactorPin;
  final double trustScore;
  final bool isVerified;
  final String role;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  String get name => '$firstName $lastName';

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.title = '',
    this.photoURL = '',
    this.skills = const [],
    this.interests = const [],
    this.bio = '',
    this.location = const LocationEntity.empty(),
    this.phone,
    this.profileComplete = false,
    this.twoFactorEnabled = false,
    this.twoFactorPin,
    this.trustScore = 0.0,
    this.isVerified = false,
    this.role = 'member',
    this.updatedAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    title,
    photoURL,
    skills,
    interests,
    bio,
    location,
    phone,
    profileComplete,
    twoFactorEnabled,
    twoFactorPin,
    trustScore,
    isVerified,
    role,
    updatedAt,
    createdAt,
  ];
}
