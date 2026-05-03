import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';

class DiscoverViewModel extends ChangeNotifier {
  final SkillsRepository _skillsRepo;

  DiscoverViewModel({
    SkillsRepository? skillsRepo,
  }) : _skillsRepo = skillsRepo ?? SkillsRepository();

  List<Skill> _allSkills = [];
  List<Skill> get allSkills => _allSkills;

  List<Skill> _filteredSkills = [];
  List<Skill> get filteredSkills => _filteredSkills;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _allSkills.map((s) => s.category).toSet().toList()..sort();
    return cats;
  }

  Future<void> loadSkills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allSkills = await _skillsRepo.listAll();
      _applyFilters();
    } catch (e) {
      _error = 'Could not load skills';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
  }

  void _applyFilters() {
    var results = List<Skill>.from(_allSkills);

    if (_searchQuery.isNotEmpty) {
      results = results.where((s) =>
        s.name.toLowerCase().contains(_searchQuery) ||
        s.description.toLowerCase().contains(_searchQuery) ||
        s.category.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    if (_selectedCategory != null) {
      results = results.where((s) => s.category == _selectedCategory).toList();
    }

    _filteredSkills = results;
    notifyListeners();
  }
}
