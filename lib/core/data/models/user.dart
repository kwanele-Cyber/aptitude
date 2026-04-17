
class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final List<String> skills;
  final List<String> interests;
  final String bio;
  final String location;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.skills,
    required this.interests,
    required this.bio,
    required this.location,
  });
}
