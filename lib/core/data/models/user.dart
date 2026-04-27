import 'package:myapp/core/data/models/location_model.dart';
import 'package:uuid/uuid.dart';

class User {
  final String uid;
  String email;
  String firstName;
  String lastName;
  String title;
  String photoURL;
  List<String> skills;
  List<String> interests;
  String bio;
  AddressModel location;
  String? phone;
  bool profileComplete = false;
  DateTime? updatedAt;
  DateTime? createdAt;

  String get displayName => "$firstName $lastName";

  User({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.photoURL,
    required this.skills,
    required this.interests,
    required this.bio,
    required this.location,
    required this.profileComplete,
    required this.createdAt,
    this.updatedAt,
    this.phone = ''
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'title': title,
      'photoURL': photoURL,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      'location': location.toJson(),
      'phone': phone,
      'profileComplete': profileComplete,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      title: json['title'] as String? ?? 'Developer',
      photoURL: json['photoURL'] as String? ?? '',
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      interests:
          (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bio: json['bio'] as String? ?? '',
      location: json['location'] is Map
          ? AddressModel.fromJson(json['location'] as Map)
          : (json['location'] is String
              ? AddressModel(
                  address: json['location'] as String,
                  latitude: 0,
                  longitude: 0,
                )
              : AddressModel.empty()),
      phone: json['phone'] as String? ?? '',
      profileComplete: json['profileComplete'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
