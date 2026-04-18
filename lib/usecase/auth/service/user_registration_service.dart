import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';

class UserRegistrationService {
  final UserRepository _userRepository;

  UserRegistrationService(this._userRepository);

  Future<User> registerUser({
    String? uid,
    required String email,
    required String displayName,
    required String photoURL,
    List<String> skills = const [],
    List<String> interests = const [],
    String bio = '',
    String location = '',
  }) async {
    final user = User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      skills: skills,
      interests: interests,
      bio: bio,
      location: location,
    );
    await _userRepository.createUnique(user);
    


    return user;
  }
}
