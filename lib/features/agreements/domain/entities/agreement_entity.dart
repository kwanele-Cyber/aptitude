import 'package:equatable/equatable.dart';

enum AgreementStatus { pending, accepted, modified, cancelled, completed }

class AgreementEntity extends Equatable {
  final String id;
  final String initiatorId;
  final String initiatorName;
  final String partnerId;
  final String partnerName;
  final String initiatorSkillId;
  final String initiatorSkillTitle;
  final String partnerSkillId;
  final String partnerSkillTitle;
  final AgreementStatus status;
  final String duration;
  final String frequency;
  final int sessionsCount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? modifiedBy;
  final String? cancelledBy;
  final DateTime? cancelledAt;

  const AgreementEntity({
    required this.id,
    required this.initiatorId,
    required this.initiatorName,
    required this.partnerId,
    required this.partnerName,
    required this.initiatorSkillId,
    required this.initiatorSkillTitle,
    required this.partnerSkillId,
    required this.partnerSkillTitle,
    this.status = AgreementStatus.pending,
    required this.duration,
    required this.frequency,
    required this.sessionsCount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.modifiedBy,
    this.cancelledBy,
    this.cancelledAt,
  });

  @override
  List<Object?> get props => [
        id,
        initiatorId,
        initiatorName,
        partnerId,
        partnerName,
        initiatorSkillId,
        initiatorSkillTitle,
        partnerSkillId,
        partnerSkillTitle,
        status,
        duration,
        frequency,
        sessionsCount,
        notes,
        createdAt,
        updatedAt,
        modifiedBy,
        cancelledBy,
        cancelledAt,
      ];
}
