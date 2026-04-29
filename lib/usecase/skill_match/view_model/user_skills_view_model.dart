import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_request.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class UserSkillsViewModel extends ChangeNotifier {
  final UserSkillsRepository _userSkillsRepo;
  final AuthService _authService;

  UserSkillsViewModel({
    UserSkillsRepository? userSkillsRepo,
    AuthService? authService,
  })  : _userSkillsRepo = userSkillsRepo ?? UserSkillsRepository(),
        _authService = authService ?? AuthService();

  List<SkillOffer> _offers = [];
  List<SkillOffer> get offers => _offers.where((o) => !o.isArchived).toList();
  List<SkillOffer> get archivedOffers => _offers.where((o) => o.isArchived).toList();

  List<SkillRequest> _requests = [];
  List<SkillRequest> get requests => _requests.where((r) => !r.isArchived).toList();
  List<SkillRequest> get archivedRequests => _requests.where((r) => r.isArchived).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchUserSkills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uid = currentUser.uid;

      // Fetch both in parallel
      final results = await Future.wait([
        _userSkillsRepo.getUserOffers(uid),
        _userSkillsRepo.getUserRequests(uid),
      ]);

      _offers = results[0] as List<SkillOffer>;
      _requests = results[1] as List<SkillRequest>;
      
    } catch (e) {
      _error = 'Failed to load skills: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveOffer(SkillOffer offer, bool archive) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = offer.copyWith(isArchived: archive);
      await _userSkillsRepo.updateOffer(updated);
      await fetchUserSkills();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveRequest(SkillRequest request, bool archive) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = request.copyWith(isArchived: archive);
      await _userSkillsRepo.updateRequest(updated);
      await fetchUserSkills();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cloneOffer(SkillOffer original) async {
    _isLoading = true;
    notifyListeners();
    try {
      final clone = SkillOffer(
        id: const Uuid().v4(),
        uid: original.uid,
        sid: original.sid,
        skillName: original.skillName,
        level: original.level,
        format: original.format,
        description: 'Copy of ${original.description}',
      );
      await _userSkillsRepo.addOffer(clone);
      await fetchUserSkills();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cloneRequest(SkillRequest original) async {
    _isLoading = true;
    notifyListeners();
    try {
      final clone = SkillRequest(
        id: const Uuid().v4(),
        uid: original.uid,
        sid: original.sid,
        skillName: original.skillName,
        targetLevel: original.targetLevel,
        preferredFormat: original.preferredFormat,
        description: 'Copy of ${original.description}',
      );
      await _userSkillsRepo.addRequest(clone);
      await fetchUserSkills();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
