import 'package:flutter/material.dart';
import 'package:myapp/core/models/match_model.dart';
import 'package:myapp/core/repositories/match_repository.dart';

class MatchViewModel extends ChangeNotifier {
  final MatchRepository _matchRepository;

  MatchViewModel(this._matchRepository);

  List<MatchModel> _matches = [];
  List<MatchModel> get matches => _matches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<MatchModel> get filteredMatches {
    return _matches.where((match) {
      // 1. Always hide ignored matches
      if (match.status == 'ignored') return false;

      // 2. Filter by status
      bool matchesStatus = _statusFilter == 'all' || match.status == _statusFilter;

      // 3. Filter by search query
      bool matchesSearch = _searchQuery.isEmpty || 
          match.skillName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> generateAndSaveMatches(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _matchRepository.generateMatches(userId);
    } catch (e) {
      _error = "Failed to generate matches.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedMatches(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _matchRepository.getMatches(userId);
    } catch (e) {
      _error = "Failed to load matches.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateMatchStatus(String matchId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _matchRepository.updateMatchStatus(matchId, newStatus);
      // Update local list to reflect changes immediately
      final index = _matches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _matches[index] = _matches[index].copyWith(status: newStatus);
      }
    } catch (e) {
      _error = "Failed to update match status.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
