import 'package:flutter/material.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  ProfileViewModel(this._userRepository);

  UserModel? _viewedUser;
  UserModel? get viewedUser => _viewedUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUserProfile(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _viewedUser = await _userRepository.getUser(uid);
      if (_viewedUser == null) {
        _error = "User not found.";
      }
    } catch (e) {
      _error = "Failed to load profile.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
