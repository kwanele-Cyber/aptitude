import 'package:flutter/material.dart';
import 'package:myapp/core/models/agreement_model.dart';
import 'package:myapp/core/repositories/agreement_repository.dart';
import 'package:uuid/uuid.dart';

class AgreementViewModel extends ChangeNotifier {
  final AgreementRepository _agreementRepository;

  AgreementViewModel(this._agreementRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<AgreementModel> _agreements = [];
  List<AgreementModel> get agreements => _agreements;

  List<AgreementModel> _history = [];
  List<AgreementModel> get history => _history;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<bool> proposeAgreement({
    required String learnerId,
    required String mentorId,
    required String learnerSkill,
    required String mentorSkill,
    required String frequency,
    required double duration,
    String? parentId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final agreement = AgreementModel(
      id: const Uuid().v4(),
      learnerId: learnerId,
      mentorId: mentorId,
      learnerSkill: learnerSkill,
      mentorSkill: mentorSkill,
      frequency: frequency,
      duration: duration,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    try {
      await _agreementRepository.createAgreement(agreement);
      return true;
    } catch (e) {
      _error = "Failed to propose agreement.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAgreements(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agreements = await _agreementRepository.getAgreementsForUser(userId);
    } catch (e) {
      _error = "Failed to load agreements.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String agreementId, AgreementStatus status) async {
    try {
      await _agreementRepository.updateAgreementStatus(agreementId, status);
      // Update local state
      final index = _agreements.indexWhere((a) => a.id == agreementId);
      if (index != -1) {
        _agreements[index] = _agreements[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update status.";
      notifyListeners();
    }
  }

  Future<void> acceptAgreement(String agreementId) async {
    await updateStatus(agreementId, AgreementStatus.accepted);
  }

  Future<void> declineAgreement(String agreementId) async {
    await updateStatus(agreementId, AgreementStatus.declined);
  }

  Future<void> cancelAgreement(String agreementId) async {
    await updateStatus(agreementId, AgreementStatus.canceled);
  }

  Future<void> loadHistory(String agreementId) async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _agreementRepository.getAgreementHistory(agreementId);
    } catch (e) {
      _error = "Failed to load history.";
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> createCounterOffer({
    required AgreementModel originalAgreement,
    required String learnerSkill,
    required String mentorSkill,
    required String frequency,
    required double duration,
  }) async {
    // 1. Decline the original agreement
    await declineAgreement(originalAgreement.id);

    // 2. Propose the new one with parentId
    return proposeAgreement(
      learnerId: originalAgreement.learnerId,
      mentorId: originalAgreement.mentorId,
      learnerSkill: learnerSkill,
      mentorSkill: mentorSkill,
      frequency: frequency,
      duration: duration,
      parentId: originalAgreement.id,
    );
  }
}
