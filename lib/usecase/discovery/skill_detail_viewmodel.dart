import 'package:flutter/material.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/repositories/user_repository.dart';

class SkillDetailViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  SkillDetailViewModel(this._userRepository);

  UserModel? _owner;
  UserModel? get owner => _owner;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadOwnerDetails(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _owner = await _userRepository.getUser(ownerId);
    } catch (e) {
      _error = "Failed to load owner details.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
