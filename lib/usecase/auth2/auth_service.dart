import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/utils/logger.dart';

class AuthService {
  late final auth.FirebaseAuth _auth;
  late final UserRepository _userRepo;

  AuthService({auth.FirebaseAuth? authService, UserRepository? userRepo}) {
    _auth = authService ?? auth.FirebaseAuth.instance;
    _userRepo = userRepo ?? UserRepository();
  }

  Future<User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = result.user;
      if (firebaseUser == null) return null;

      final newUser = User(
        uid: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        title: 'User', // Default title
        photoURL: '',
        skills: [],
        interests: [],
        bio: '',
        location: AddressModel.empty(),
      );

      await _userRepo.create(newUser);
      return newUser;
    } catch (e, stackTrace) {
      Log.e('Registration error: $e', e, stackTrace);
      return null;
    }
  }

  Future<auth.User?> login(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e, stackTrace) {
      Log.e('Login error: $e', e, stackTrace);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _userRepo.read(firebaseUser.uid);
    } catch (e, stackTrace) {
      Log.e('Error fetching current user: $e', e, stackTrace);
      return null;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user logged in');
    }

    try {
      auth.AuthCredential credential = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }
}