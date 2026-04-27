import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';

extension UserExtension on User {
  User copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? title,
    String? photoURL,
    List<String>? skills,
    List<String>? interests,
    String? bio,
    AddressModel? location,
    bool? profileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      title: title ?? this.title,
      photoURL: photoURL ?? this.photoURL,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
