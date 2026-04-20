import 'package:uuid/uuid.dart';

class User {
  String uid;
  final String email;
  final String displayName;
  final String photoURL;
  //TODO: update the skills model to include the skills model instead of just a list of string.
  final List<String> skills;
  //TODO: update the interests model to include the skills model instead of just a list of string.
  final List<String> interests;
  final String bio;
  final String location;

  User({
    String? uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.skills,
    required this.interests,
    required this.bio,
    required this.location,
  }) : uid = uid ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      'location': location,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      skills: List<String>.from(json['skills']),
      interests: List<String>.from(json['interests']),
      bio: json['bio'],
      location: json['location'],
    );
  }
}
