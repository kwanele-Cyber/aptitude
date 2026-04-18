import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Set loading state and notify listeners
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Login method
  Future<bool> login() async {
    _setLoading(true);
    _errorMessage = null; // Clear previous errors

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _setLoading(false);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      if (kDebugMode) print("Firebase Auth Error: $e");
      _setLoading(false);
      return false; // Failure
    } catch (e) {
      _errorMessage = "An unknown error occurred.";
      if (kDebugMode) print("General Error: $e");
      _setLoading(false);
      return false; // Failure
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
