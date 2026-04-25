import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> register(
      String name,
      String email,
      String phone,
      String password,
      ) async {
    try {
      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Save extra data to Firestore
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "name": name,
          "email": email,
          "phone": phone,
          "uid": user.uid,
        });
      }

      return user;
    } catch (e) {
      // Re-throw the exception to be handled by the UI
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // Re-throw the exception to be handled by the UI
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
