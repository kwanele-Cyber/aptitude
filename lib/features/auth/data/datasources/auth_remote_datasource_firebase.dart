import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myapp/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceFirebase implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  AuthRemoteDataSourceFirebase({FirebaseAuth? auth, FirebaseDatabase? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? FirebaseDatabase.instance;

  DatabaseReference _userRef(String uid) => _database.ref('users/$uid');

  Future<UserModel> _getUserFromDatabase(String uid) async {
    final snapshot = await _userRef(uid).get();
    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.value as Map<String, dynamic>);
    }
    final firebaseUser = _auth.currentUser!;
    return UserModel(
      id: uid,
      firstName: firebaseUser.displayName?.split(' ').firstOrNull ?? '',
      lastName: firebaseUser.displayName?.split(' ').lastOrNull ?? '',
      email: firebaseUser.email ?? '',
      photoURL: firebaseUser.photoURL ?? '',
      isVerified: firebaseUser.emailVerified,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserFromDatabase(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        throw InvalidCredentialsException();
      }
      throw ServerException();
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userRef(uid).set(user.toJson());
      return user;
    } on FirebaseAuthException {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      throw ServerException();
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _userRef(user.uid).remove();
        await user.delete();
      }
    } on FirebaseAuthException {
      throw ServerException();
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException {
      throw ServerException();
    }
  }

  @override
  Future<bool> verify2FAPin(String uid, String pin) async {
    try {
      final snapshot = await _userRef(uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<String, dynamic>?;
        final storedPin = data?['twoFactorPin'] as String?;
        return storedPin == pin;
      }
      return false;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerException();

      await _userRef(user.uid).update(data);
      return _getUserFromDatabase(user.uid);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<String>> generateRecoveryCodes() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();
      final rng = Random.secure();
      final codes = List.generate(10, (_) {
        final bytes = List<int>.generate(12, (_) => rng.nextInt(256));
        return base64Url.encode(bytes).substring(0, 16);
      });

      final codeMap = <String, dynamic>{};
      for (final code in codes) {
        final hash = sha256.convert(utf8.encode(code)).toString();
        codeMap[hash] = false; // false = not consumed
      }

      await _userRef(uid).child('recoveryCodes').set(codeMap);
      return codes;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> recoverAccount(String email, String recoveryCode) async {
    try {
      // Find user by email in RTDB
      final usersSnapshot = await _database.ref('users').get();
      if (!usersSnapshot.exists) throw InvalidCredentialsException();

      final users = usersSnapshot.value as Map<dynamic, dynamic>;
      String? uid;
      for (final entry in users.entries) {
        final userData = entry.value as Map<dynamic, dynamic>?;
        if (userData?['email'] == email) {
          uid = entry.key;
          break;
        }
      }

      if (uid == null) throw InvalidCredentialsException();

      // Verify the recovery code
      final codeHash = sha256.convert(utf8.encode(recoveryCode)).toString();
      final codesSnapshot = await _userRef(uid).child('recoveryCodes/$codeHash').get();

      if (!codesSnapshot.exists || codesSnapshot.value == true) {
        throw InvalidCredentialsException();
      }

      // Mark code as consumed and send password reset
      await _userRef(uid).child('recoveryCodes/$codeHash').set(true);
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is InvalidCredentialsException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final snapshot = await _userRef(uid).get();
      if (!snapshot.exists) throw ServerException();
      return UserModel.fromJson(snapshot.value as Map<String, dynamic>);
    } catch (e) {
      throw ServerException();
    }
  }
}
