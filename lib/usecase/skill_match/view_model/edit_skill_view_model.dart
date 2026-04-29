import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/data/models/skill_proof.dart';

class EditSkillViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserSkillsRepository _userSkillsRepo;

  EditSkillViewModel({
    AuthService? authService,
    UserSkillsRepository? userSkillsRepo,
  })  : _authService = authService ?? AuthService(),
        _userSkillsRepo = userSkillsRepo ?? UserSkillsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SkillOffer? _offer;
  SkillRequest? _request;
  bool _isOffer = true;

  String _skillName = '';
  String get skillName => _skillName;

  SkillLevel _level = SkillLevel.beginner;
  SkillLevel get level => _level;

  SkillFormat _format = SkillFormat.online;
  SkillFormat get format => _format;

  String _description = '';
  String get description => _description;

  List<SkillProof> _proofs = [];
  List<SkillProof> get proofs => _proofs;

  int _yearsOfExperience = 0;
  int get yearsOfExperience => _yearsOfExperience;

  Future<void> loadItem(String id, bool isOffer) async {
    _isLoading = true;
    _isOffer = isOffer;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not logged in');

      if (isOffer) {
        _offer = await _userSkillsRepo.getOffer(currentUser.uid, id);
        if (_offer != null) {
          _skillName = _offer!.skillName;
          _level = _offer!.level;
          _format = _offer!.format;
          _description = _offer!.description;
          _proofs = List.from(_offer!.proofs);
          _yearsOfExperience = _offer!.yearsOfExperience;
        }
      } else {
        _request = await _userSkillsRepo.getRequest(currentUser.uid, id);
        if (_request != null) {
          _skillName = _request!.skillName;
          _level = _request!.targetLevel;
          _format = _request!.preferredFormat;
          _description = _request!.description;
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  void addProof(SkillProof proof) {
    _proofs.add(proof);
    notifyListeners();
  }

  void removeProof(String proofId) {
    _proofs.removeWhere((p) => p.id == proofId);
    notifyListeners();
  }

  void updateYearsOfExperience(int val) {
    _yearsOfExperience = val;
    notifyListeners();
  }

  Future<bool> updateItem() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOffer && _offer != null) {
        final updatedOffer = _offer!.copyWith(
          level: _level,
          format: _format,
          description: _description,
          proofs: _proofs,
          yearsOfExperience: _yearsOfExperience,
        );
        await _userSkillsRepo.updateOffer(updatedOffer);
      } else if (!_isOffer && _request != null) {
        final updatedRequest = _request!.copyWith(
          targetLevel: _level,
          preferredFormat: _format,
          description: _description,
        );
        await _userSkillsRepo.updateRequest(updatedRequest);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      if (_isOffer && _offer != null) {
        await _userSkillsRepo.deleteOffer(currentUser.uid, _offer!.id);
      } else if (!_isOffer && _request != null) {
        await _userSkillsRepo.deleteRequest(currentUser.uid, _request!.id);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
