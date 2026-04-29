import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';

class CreateSkillOfferViewModel extends ChangeNotifier {
  final AuthService _authService;
  final SkillsRepository _skillsRepo;
  final UserSkillsRepository _userSkillsRepo;

  CreateSkillOfferViewModel({
    AuthService? authService,
    SkillsRepository? skillsRepo,
    UserSkillsRepository? userSkillsRepo,
  })  : _authService = authService ?? AuthService(),
        _skillsRepo = skillsRepo ?? SkillsRepository(),
        _userSkillsRepo = userSkillsRepo ?? UserSkillsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _skillName = '';
  SkillLevel _level = SkillLevel.beginner;
  SkillLevel get level => _level;

  SkillFormat _format = SkillFormat.online;
  SkillFormat get format => _format;

  String _description = '';
  String get description => _description;

  void updateSkillName(String val) {
    _skillName = val;
    notifyListeners();
  }

  void updateLevel(SkillLevel val) {
    _level = val;
    notifyListeners();
  }

  void updateFormat(SkillFormat val) {
    _format = val;
    notifyListeners();
  }

  void updateDescription(String val) {
    _description = val;
    notifyListeners();
  }

  Future<bool> saveOffer() async {
    if (_skillName.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not logged in');

      // 1. Resolve skill ID (checks global list, creates if new)
      final sid = await _skillsRepo.resolveSkillId(_skillName);

      // 2. Create SkillOffer
      final offer = SkillOffer(
        uid: currentUser.uid,
        sid: sid,
        skillName: _skillName,
        level: _level,
        format: _format,
        description: _description,
      );

      // 3. Save to UserSkillsRepository
      await _userSkillsRepo.addOffer(offer);

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
