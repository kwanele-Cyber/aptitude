import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';

class CreateSkillRequestViewModel extends ChangeNotifier {
  final AuthService _authService;
  final SkillsRepository _skillsRepo;
  final UserSkillsRepository _userSkillsRepo;

  CreateSkillRequestViewModel({
    AuthService? authService,
    SkillsRepository? skillsRepo,
    UserSkillsRepository? userSkillsRepo,
  })  : _authService = authService ?? AuthService(),
        _skillsRepo = skillsRepo ?? SkillsRepository(),
        _userSkillsRepo = userSkillsRepo ?? UserSkillsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _skillName = '';
  SkillLevel _targetLevel = SkillLevel.beginner;
  SkillLevel get targetLevel => _targetLevel;

  SkillFormat _preferredFormat = SkillFormat.online;
  SkillFormat get preferredFormat => _preferredFormat;

  String _description = '';
  String get description => _description;

  void updateSkillName(String val) {
    _skillName = val;
    notifyListeners();
  }

  void updateTargetLevel(SkillLevel val) {
    _targetLevel = val;
    notifyListeners();
  }

  void updatePreferredFormat(SkillFormat val) {
    _preferredFormat = val;
    notifyListeners();
  }

  void updateDescription(String val) {
    _description = val;
    notifyListeners();
  }

  Future<bool> saveRequest() async {
    if (_skillName.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not logged in');

      // 1. Resolve skill ID
      final sid = await _skillsRepo.resolveSkillId(_skillName);

      // 2. Create SkillRequest
      final request = SkillRequest(
        uid: currentUser.uid,
        sid: sid,
        skillName: _skillName,
        targetLevel: _targetLevel,
        preferredFormat: _preferredFormat,
        description: _description,
      );

      // 3. Save to UserSkillsRepository
      await _userSkillsRepo.addRequest(request);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
