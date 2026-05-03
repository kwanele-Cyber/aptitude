import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:myapp/core/data/models/match_result.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/services/match_service.dart';
import 'package:myapp/core/data/repositories/block_repository.dart';
import 'package:myapp/core/data/repositories/match_repository.dart';
import 'package:myapp/core/data/repositories/chat_repository.dart';
import 'package:myapp/core/error/error_handler.dart';

class MatchesViewModel extends ChangeNotifier {
  final AuthService _authService;
  final MatchService _matchService;
  final BlockRepository _blockRepo;
  final MatchRepository _matchRepo;
  final ChatRepository _chatRepo;

  MatchesViewModel({
    AuthService? authService,
    MatchService? matchService,
    BlockRepository? blockRepo,
    MatchRepository? matchRepo,
    ChatRepository? chatRepo,
  })  : _authService = authService ?? AuthService(),
        _matchService = matchService ?? MatchService(),
        _blockRepo = blockRepo ?? BlockRepository(),
        _matchRepo = matchRepo ?? MatchRepository(),
        _chatRepo = chatRepo ?? ChatRepository();

  List<MatchResult> _matches = [];
  List<MatchResult> get matches => _matches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Filter state
  final Set<SkillLevel> _selectedLevels = {};
  Set<SkillLevel> get selectedLevels => _selectedLevels;

  final Set<SkillFormat> _selectedFormats = {};
  Set<SkillFormat> get selectedFormats => _selectedFormats;

  String? _selectedSkillId;
  String? get selectedSkillId => _selectedSkillId;

  String? _selectedSkillName;
  String? get selectedSkillName => _selectedSkillName;

  double _minTrustScore = 0.0;
  double get minTrustScore => _minTrustScore;

  bool _onlyVerified = false;
  bool get onlyVerified => _onlyVerified;

  Future<void> loadMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');

      final allMatches = await _matchService.getRankedMatches(currentUser.uid);
      final blockedUids = await _blockRepo.getBlockedList(currentUser.uid);

      // Apply UI filters (M10) + Safety filters (X15)
      _matches = allMatches.where((m) {
        // 0. Safety: Blocked users
        if (blockedUids.contains(m.peer.uid)) {
          return false;
        }

        // 1. Skill Search Filter
        if (_selectedSkillId != null && !m.peer.skills.contains(_selectedSkillId)) {
          return false;
        }

        // 2. Proficiency Level Filter
        if (_selectedLevels.isNotEmpty) {
           // Logic for level matching
           return true;
        }

        // 3. Trust Score Filter (M10)
        if (m.peer.trustScore < _minTrustScore) {
          return false;
        }

        // 4. Verified Filter (M10)
        if (_onlyVerified && !m.peer.isVerified) {
          return false;
        }

        return true;
      }).toList();

    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      ErrorHandler.log(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLevel(SkillLevel level) async {
    if (_selectedLevels.contains(level)) {
      _selectedLevels.remove(level);
    } else {
      _selectedLevels.add(level);
    }
    await loadMatches();
  }

  Future<void> toggleFormat(SkillFormat format) async {
    if (_selectedFormats.contains(format)) {
      _selectedFormats.remove(format);
    } else {
      _selectedFormats.add(format);
    }
    await loadMatches();
  }

  Future<void> setSkill(String? id, String? name) async {
    _selectedSkillId = id;
    _selectedSkillName = name;
    await loadMatches();
  }

  Future<void> setMinTrustScore(double score) async {
    _minTrustScore = score;
    await loadMatches();
  }

  Future<void> setOnlyVerified(bool value) async {
    _onlyVerified = value;
    await loadMatches();
  }

  Future<void> clearFilters() async {
    _selectedLevels.clear();
    _selectedFormats.clear();
    _selectedSkillId = null;
    _selectedSkillName = null;
    _minTrustScore = 0.0;
    _onlyVerified = false;
    await loadMatches();
  }

  Future<void> acceptMatch(MatchResult match) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      await _matchRepo.acceptMatch(currentUser.uid, match.peer.uid);

      final chatId = _chatRepo.getChannelId(currentUser.uid, match.peer.uid);
      final existing = await _chatRepo.getChannel(chatId);

      if (existing == null) {
        final common = [
          ...match.matchingOffers.map((o) => o.skillName),
          ...match.matchingRequests.map((r) => r.skillName),
        ];

        await _chatRepo.createChannel(ChatChannel(
          id: chatId,
          participants: [currentUser.uid, match.peer.uid]..sort(),
          commonSkills: common,
          lastMessage: "System: Match created! Say hello.",
          lastMessageTimestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      _matches.removeWhere((m) => m.peer.uid == match.peer.uid);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      ErrorHandler.log(e);
      notifyListeners();
    }
  }

  Future<void> rejectMatch(MatchResult match) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      await _matchRepo.rejectMatch(currentUser.uid, match.peer.uid);

      _matches.removeWhere((m) => m.peer.uid == match.peer.uid);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      ErrorHandler.log(e);
      notifyListeners();
    }
  }

  Future<void> ignoreMatch(MatchResult match) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      await _matchRepo.ignoreMatch(currentUser.uid, match.peer.uid);

      _matches.removeWhere((m) => m.peer.uid == match.peer.uid);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      ErrorHandler.log(e);
      notifyListeners();
    }
  }

  Future<void> saveMatch(MatchResult match) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      await _matchRepo.saveMatch(currentUser.uid, match.peer.uid);

      _matches.removeWhere((m) => m.peer.uid == match.peer.uid);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      ErrorHandler.log(e);
      notifyListeners();
    }
  }
}
