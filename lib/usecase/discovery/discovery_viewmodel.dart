import 'package:flutter/material.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/repositories/skill_repository.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final SkillRepository _skillRepository;

  DiscoveryViewModel(this._skillRepository);

  List<SkillModel> _searchResults = [];
  List<SkillModel> get searchResults => _searchResults;

  String? _selectedLevel;
  String? get selectedLevel => _selectedLevel;

  String? _selectedType;
  String? get selectedType => _selectedType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setLevelFilter(String? level) {
    _selectedLevel = level;
    _applyFilters();
  }

  void setTypeFilter(String? type) {
    _selectedType = type;
    _applyFilters();
  }

  List<SkillModel> _allSkills = [];

  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allSkills = await _skillRepository.searchSkills(query);
      _applyFilters();
    } catch (e) {
      _error = "Search failed.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _searchResults = _allSkills.where((skill) {
      final matchesLevel = _selectedLevel == null || skill.level == _selectedLevel;
      final matchesType = _selectedType == null || skill.type == _selectedType;
      return matchesLevel && matchesType;
    }).toList();
    notifyListeners();
  }

  Future<void> loadInitialSkills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allSkills = await _skillRepository.getRecentSkills();
      _applyFilters();
    } catch (e) {
      _error = "Failed to load skills feed.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
