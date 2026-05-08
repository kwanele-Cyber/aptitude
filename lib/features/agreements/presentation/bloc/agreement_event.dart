import 'package:equatable/equatable.dart';

abstract class AgreementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateAgreementRequested extends AgreementEvent {
  final String initiatorId;
  final String initiatorName;
  final String partnerId;
  final String partnerName;
  final String initiatorSkillId;
  final String initiatorSkillTitle;
  final String partnerSkillId;
  final String partnerSkillTitle;
  final String duration;
  final String frequency;
  final int sessionsCount;
  final String? notes;

  CreateAgreementRequested({
    required this.initiatorId,
    required this.initiatorName,
    required this.partnerId,
    required this.partnerName,
    required this.initiatorSkillId,
    required this.initiatorSkillTitle,
    required this.partnerSkillId,
    required this.partnerSkillTitle,
    required this.duration,
    required this.frequency,
    required this.sessionsCount,
    this.notes,
  });

  @override
  List<Object?> get props => [
        initiatorId,
        initiatorName,
        partnerId,
        partnerName,
        initiatorSkillId,
        initiatorSkillTitle,
        partnerSkillId,
        partnerSkillTitle,
        duration,
        frequency,
        sessionsCount,
        notes,
      ];
}

class AcceptAgreementRequested extends AgreementEvent {
  final String agreementId;
  final String userId;

  AcceptAgreementRequested({
    required this.agreementId,
    required this.userId,
  });

  @override
  List<Object?> get props => [agreementId, userId];
}

class ModifyAgreementRequested extends AgreementEvent {
  final String agreementId;
  final String userId;
  final String duration;
  final String frequency;
  final int sessionsCount;
  final String? notes;

  ModifyAgreementRequested({
    required this.agreementId,
    required this.userId,
    required this.duration,
    required this.frequency,
    required this.sessionsCount,
    this.notes,
  });

  @override
  List<Object?> get props => [
        agreementId,
        userId,
        duration,
        frequency,
        sessionsCount,
        notes,
      ];
}

class CancelAgreementRequested extends AgreementEvent {
  final String agreementId;
  final String userId;

  CancelAgreementRequested({
    required this.agreementId,
    required this.userId,
  });

  @override
  List<Object?> get props => [agreementId, userId];
}

class FetchAgreementsRequested extends AgreementEvent {
  final String userId;

  FetchAgreementsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchAgreementByIdRequested extends AgreementEvent {
  final String agreementId;

  FetchAgreementByIdRequested({required this.agreementId});

  @override
  List<Object?> get props => [agreementId];
}
