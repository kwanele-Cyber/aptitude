import 'package:myapp/core/data/models/user.dart';

extension UserExtension on User {
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? skills,
    List<String>? interests,
    String? bio,
    String? location,
  }) {
    return User(
      // If a new value is passed, use it. 
      // Otherwise, use 'this' (the current instance's value).
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      location: location ?? this.location,
    );
  }
}