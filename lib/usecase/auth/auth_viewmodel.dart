import 'package:flutter/material.dart';
import 'package:myapp/core/repositories/auth_repository.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';
import 'package:myapp/core/services/location_service.dart';
import 'dart:async';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LocationService _locationService;
  Timer? _locationTimer;

  AuthViewModel(this._authRepository, this._locationService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UserModel? _user;
  UserModel? get user => _user;

  bool get isAdmin => _user?.role == UserRole.admin;

  List<SkillModel> _offeredSkills = [];
  List<SkillModel> get offeredSkills => _offeredSkills;

  List<SkillModel> _desiredSkills = [];
  List<SkillModel> get desiredSkills => _desiredSkills;

  void addOfferedSkill(SkillModel skill) {
    _offeredSkills.add(skill);
    notifyListeners();
  }

  void removeOfferedSkill(SkillModel skill) {
    _offeredSkills.remove(skill);
    notifyListeners();
  }

  void addDesiredSkill(SkillModel skill) {
    _desiredSkills.add(skill);
    notifyListeners();
  }

  void removeDesiredSkill(SkillModel skill) {
    _desiredSkills.remove(skill);
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      _error = "Please enter a valid email address.";
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _error = "Password must be at least 6 characters long.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      _user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _startLocationTracking();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "An unexpected error occurred.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfile() async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      final updatedUser = _user!.copyWith(
        offeredSkills: _offeredSkills,
        desiredSkills: _desiredSkills,
      );
      await _authRepository.updateUser(updatedUser);
      _user = updatedUser;
      return true;
    } catch (e) {
      _error = "Failed to update profile.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      _startLocationTracking();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "An unexpected error occurred.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;

    try {
      await _authRepository.signOut();
      _user = null;
      _offeredSkills = [];
      _desiredSkills = [];
      notifyListeners();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "An unexpected error occurred during logout.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfileChanges({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      final updatedUser = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        photoUrl: photoUrl ?? _user!.photoUrl,
        offeredSkills: _offeredSkills,
        desiredSkills: _desiredSkills,
      );
      await _authRepository.updateUser(updatedUser);
      _user = updatedUser;
      return true;
    } catch (e) {
      _error = "Failed to save changes.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;

    _setLoading(true);
    try {
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser != null) {
        _user = updatedUser;
        _offeredSkills = List.from(updatedUser.offeredSkills);
        _desiredSkills = List.from(updatedUser.desiredSkills);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to refresh profile.";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  void _startLocationTracking() {
    _locationTimer?.cancel();
    // Initial update
    _updateLocation();
    // Periodic update every 5 minutes (M04 Requirement)
    _locationTimer = Timer.periodic(const Duration(minutes: 5), (_) => _updateLocation());
  }

  Future<void> _updateLocation() async {
    if (_user == null) return;
    
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final newLocation = _locationService.positionToLocationModel(position);
        final updatedUser = _user!.copyWith(location: newLocation);
        await _authRepository.updateUser(updatedUser);
        _user = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      // Background failure is silent
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
