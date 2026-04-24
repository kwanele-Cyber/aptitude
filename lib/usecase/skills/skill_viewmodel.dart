import 'package:flutter/material.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/repositories/skill_repository.dart';

class SkillViewModel extends ChangeNotifier {
  final SkillRepository _skillRepository;

  SkillViewModel(this._skillRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> createSkillOffer({
    required String userId,
    required String name,
    required String description,
    required String level,
  }) async {
    if (name.isEmpty) {
      _error = "Skill name cannot be empty.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final skill = SkillModel(
        id: '', // Will be generated in repo or here
        name: name,
        description: description,
        level: level,
      );

      await _skillRepository.createSkill(
        skill: skill,
        userId: userId,
        isOffer: true,
      );
      return true;
    } catch (e) {
      _error = "Failed to create skill offer.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSkillRequest({
    required String userId,
    required String name,
    required String description,
    required String level,
  }) async {
    if (name.isEmpty) {
      _error = "Skill name cannot be empty.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final skill = SkillModel(
        id: '',
        name: name,
        description: description,
        level: level,
      );

      await _skillRepository.createSkill(
        skill: skill,
        userId: userId,
        isOffer: false,
      );
      return true;
    } catch (e) {
      _error = "Failed to create skill request.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSkill({
    required String userId,
    required SkillModel skill,
  }) async {
    if (skill.name.isEmpty) {
      _error = "Skill name cannot be empty.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _skillRepository.updateSkill(
        skill: skill,
        userId: userId,
      );
      return true;
    } catch (e) {
      _error = "Failed to update skill.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSkill({
    required String skillId,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _skillRepository.deleteSkill(
        skillId: skillId,
        userId: userId,
      );
      return true;
    } catch (e) {
      _error = "Failed to delete skill.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
