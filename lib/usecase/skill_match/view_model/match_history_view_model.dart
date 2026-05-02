import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/match.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/repositories/match_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/auth_service.dart';

class MatchHistoryItem {
  final Match match;
  final User peer;

  MatchHistoryItem({required this.match, required this.peer});
}

class MatchHistoryViewModel extends ChangeNotifier {
  final MatchRepository _matchRepo;
  final UserRepository _userRepo;
  final AuthService _authService;

  MatchHistoryViewModel({
    MatchRepository? matchRepo,
    UserRepository? userRepo,
    AuthService? authService,
  })  : _matchRepo = matchRepo ?? MatchRepository(),
        _userRepo = userRepo ?? UserRepository(),
        _authService = authService ?? AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MatchHistoryItem> _allHistory = [];
  
  List<MatchHistoryItem> get accepted => _allHistory.where((m) => m.match.status == MatchStatus.accepted).toList();
  List<MatchHistoryItem> get saved => _allHistory.where((m) => m.match.status == MatchStatus.saved).toList();
  List<MatchHistoryItem> get rejected => _allHistory.where((m) => m.match.status == MatchStatus.rejected).toList();
  List<MatchHistoryItem> get ignored => _allHistory.where((m) => m.match.status == MatchStatus.ignored).toList();

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');

      final matches = await _matchRepo.getUserMatches(currentUser.uid);
      List<MatchHistoryItem> items = [];

      for (var match in matches) {
        final peerUid = match.participants.firstWhere((id) => id != currentUser.uid);
        final peer = await _userRepo.read(peerUid);
        if (peer != null) {
          items.add(MatchHistoryItem(match: match, peer: peer));
        }
      }

      _allHistory = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String matchId, MatchStatus status) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      await _matchRepo.updateMatchStatus(matchId, status, currentUser.uid);
      await loadHistory(); // Refresh
    } catch (e) {
      _error = "Failed to update: $e";
      notifyListeners();
    }
  }
}
