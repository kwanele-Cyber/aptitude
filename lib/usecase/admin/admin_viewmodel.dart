import 'package:flutter/material.dart';
import 'package:myapp/core/repositories/admin_repository.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/agreement_model.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  AdminViewModel(this._adminRepository);

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  List<AgreementModel> _agreements = [];
  List<AgreementModel> get agreements => _agreements;

  List<String> _systemLogs = [];
  List<String> get systemLogs => _systemLogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminRepository.getAllUsers(),
        _adminRepository.getAllAgreements(),
      ]);
      
      _users = results[0] as List<UserModel>;
      _agreements = results[1] as List<AgreementModel>;

      // Mock System Logs
      _systemLogs = [
        "System: Dashboard data refreshed.",
        "Security: Admin login detected from IP 192.168.1.1",
        "Action: User 'Jane Doe' updated their skills profile.",
        "System: Database sync completed for ${agreements.length} agreements.",
        "Audit: New skill offer 'Flutter' created by user_1.",
      ];
    } catch (e) {
      _error = "Failed to load dashboard data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _adminRepository.deleteUser(uid);
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
    } catch (e) {
      _error = "Failed to delete user.";
      notifyListeners();
    }
  }

  Future<void> promoteToAdmin(String uid) async {
    try {
      await _adminRepository.updateUserRole(uid, UserRole.admin);
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: UserRole.admin);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update role.";
      notifyListeners();
    }
  }

  Future<void> toggleSuspension(String uid, bool isSuspended) async {
    try {
      await _adminRepository.toggleUserSuspension(uid, isSuspended);
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isSuspended: isSuspended);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update suspension status.";
      notifyListeners();
    }
  }
}
