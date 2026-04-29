import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/interfaces/auth_service_interface.dart';
import 'package:myapp/core/utils/logger.dart';

class AuthService implements AuthServiceInterface {
  final firebase.FirebaseAuth _firebaseAuth;
  final UserRepository _userRepo;

  AuthService({
    firebase.FirebaseAuth? firebaseAuth,
    UserRepository? userRepo,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _userRepo = userRepo ?? UserRepository();

  @override
  Stream<firebase.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  firebase.User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<firebase.User?> login(String email, String password) async {
    final result = await signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  @override
  Future<void> logout() => signOut();

  @override
  Future<model.User?> getCurrentUser() => getCurrentUserModel();

  @override
  Future<model.User?> getCurrentUserModel() async {
    final fUser = _firebaseAuth.currentUser;
    if (fUser == null) return null;
    try {
      return await _userRepo.read(fUser.uid);
    } catch (e, stackTrace) {
      Log.e('Error fetching current user model: $e', e, stackTrace);
      return null;
    }
  }

  @override
  Future<firebase.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    try {
      return _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<model.User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fUser = result.user;
      if (fUser == null) return null;

      await fUser.sendEmailVerification();

      final newUser = model.User(
        uid: fUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        title: 'User',
        photoURL: '',
        skills: [],
        interests: [],
        bio: '',
        location: AddressModel.empty(),
        createdAt: DateTime.now(),
        profileComplete: false,
      );

      await _userRepo.create(newUser);
      return newUser;
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> reauthenticateWithCredential(firebase.AuthCredential credential) {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw firebase.FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }
    return user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw firebase.FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }
    return user.updatePassword(newPassword);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw firebase.FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }

    try {
      firebase.AuthCredential credential = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else if (user == null) {
      throw Exception('No user logged in to resend verification.');
    }
  }
}
