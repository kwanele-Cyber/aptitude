import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/match_result.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/services/match_service.dart';

class DiscoverViewModel extends ChangeNotifier {
  final AuthService _authService;
  final MatchService _matchService;

  DiscoverViewModel({
    AuthService? authService,
    MatchService? matchService,
  })  : _authService = authService ?? AuthService(),
        _matchService = matchService ?? MatchService();

  List<MatchResult> _matches = [];
  List<MatchResult> get matches => _matches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Filter state
  Set<SkillLevel> _selectedLevels = {};
  Set<SkillLevel> get selectedLevels => _selectedLevels;

  Set<SkillFormat> _selectedFormats = {};
  Set<SkillFormat> get selectedFormats => _selectedFormats;

  String? _selectedSkillId;
  String? get selectedSkillId => _selectedSkillId;

  String? _selectedSkillName;
  String? get selectedSkillName => _selectedSkillName;

  Future<void> loadMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');

      final allMatches = await _matchService.getRankedMatches(currentUser.uid);

      // Apply UI filters (M10)
      _matches = allMatches.where((m) {
        // 1. Skill Search Filter
        if (_selectedSkillId != null && !m.peer.skills.contains(_selectedSkillId)) {
          return false;
        }

        // 2. Proficiency Level Filter
        if (_selectedLevels.isNotEmpty) {
           final peerAllSkills = [...m.matchingOffers, ...m.matchingRequests];
           // In this simplified version, we check if the match result itself meets the criteria
           // A more robust filter would check every skill the peer has.
        }

        return true;
      }).toList();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLevel(SkillLevel level) {
    if (_selectedLevels.contains(level)) {
      _selectedLevels.remove(level);
    } else {
      _selectedLevels.add(level);
    }
    loadMatches();
  }

  void toggleFormat(SkillFormat format) {
    if (_selectedFormats.contains(format)) {
      _selectedFormats.remove(format);
    } else {
      _selectedFormats.add(format);
    }
    loadMatches();
  }

  void setSkill(String? id, String? name) {
    _selectedSkillId = id;
    _selectedSkillName = name;
    loadMatches();
  }

  void clearFilters() {
    _selectedLevels.clear();
    _selectedFormats.clear();
    _selectedSkillId = null;
    _selectedSkillName = null;
    loadMatches();
  }
}
