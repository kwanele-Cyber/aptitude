import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:myapp/core/data/models/user.dart' as model;

abstract class AuthServiceInterface {
  /// Stream of user authentication state changes.
  Stream<firebase.User?> get authStateChanges;

  /// Returns the current firebase user, if any.
  firebase.User? get currentUser;

  /// Returns the app-specific User model for the current session.
  Future<model.User?> getCurrentUserModel();

  /// Alias for getCurrentUserModel.
  Future<model.User?> getCurrentUser();

  /// Signs in with email and password.
  Future<firebase.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Compatibility login method.
  Future<firebase.User?> login(String email, String password);

  /// Creates a new user and a database profile.
  Future<model.User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Alias for signOut.
  Future<void> logout();

  /// Reauthenticates the current user.
  Future<void> reauthenticateWithCredential(firebase.AuthCredential credential);

  /// Updates the password of the current user.
  Future<void> updatePassword(String newPassword);

  /// Changes the password with re-authentication.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Resends email verification.
  Future<void> resendEmailVerification();

  /// Sends a password reset email.
  Future<void> resetPassword(String email);

  /// Deletes the current user account and data.
  Future<void> deleteAccount();

  /// Verifies the 2FA PIN for a user.
  Future<bool> verify2FAPin(String uid, String pin);
}
