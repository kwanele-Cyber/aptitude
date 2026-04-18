import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/usecase/auth/service/user_registration_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRegistrationService _userRegistrationService;

  RegisterViewModel(this._userRegistrationService);

  // Controllers for registration form
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController photoURLController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Sign up method
  Future<bool> signup() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Register user details in the database
      await _userRegistrationService.registerUser(
        uid: userCredential.user!.uid,
        email: emailController.text.trim(),
        displayName: displayNameController.text.trim(),
        photoURL: photoURLController.text.trim(),
        skills: skillsController.text.split(',').map((s) => s.trim()).toList(),
        interests: interestsController.text.split(',').map((i) => i.trim()).toList(),
        bio: bioController.text.trim(),
        location: locationController.text.trim(),
      );
      
      _clearControllers();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _clearControllers();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    displayNameController.clear();
    photoURLController.clear();
    skillsController.clear();
    interestsController.clear();
    bioController.clear();
    locationController.clear();
  }
}
