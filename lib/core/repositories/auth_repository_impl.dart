import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';
import 'package:myapp/core/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseDatabaseService
    implements AuthRepository {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  AuthRepositoryImpl({FirebaseDatabase? database, String pathPrefix = ''}) 
      : super(database: database, pathPrefix: pathPrefix);

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getCurrentUser();
    });
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException("User creation failed", "auth-failed");
      }

      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        offeredSkills: [],
        desiredSkills: [],
        availability: {},
        trustScore: 0.0,
        createdAt: DateTime.now(),
      );

      await setData(path: 'users/${newUser.uid}', data: newUser.toJson());

      return newUser;
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Sign up failed", e.code);
    } catch (e) {
      throw AuthException(
        "An unexpected error occurred during sign up: ${e.toString()}",
      );
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException("Sign in failed", "auth-failed");
      }

      return await getCurrentUser() ??
          (throw AuthException("User data not found", "not-found"));
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Sign in failed", e.code);
    } catch (e) {
      throw AuthException(
        "An unexpected error occurred during sign in: ${e.toString()}",
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await getData('users/${user.uid}');
      if (snapshot.exists && snapshot.value != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await setData(path: 'users/${user.uid}', data: user.toJson());
    } catch (e) {
      throw AuthException("Failed to update user data", "update-failed");
    }
  }
}

