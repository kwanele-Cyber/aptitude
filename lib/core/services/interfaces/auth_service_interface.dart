import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthServiceInterface {
  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges;

  /// Returns the current user, if any.
  User? get currentUser;

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Creates a new user with email and password.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Reauthenticates the current user.
  Future<void> reauthenticateWithCredential(AuthCredential credential);

  /// Updates the password of the current user.
  Future<void> updatePassword(String newPassword);
}
