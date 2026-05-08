import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class CreateAgreementUseCase {
  final AgreementRepository repository;

  CreateAgreementUseCase({required this.repository});

  Future<Either<Failure, AgreementEntity>> call(
      CreateAgreementParams params) async {
    return repository.createAgreement(
      params.initiatorId,
      params.initiatorName,
      params.partnerId,
      params.partnerName,
      params.initiatorSkillId,
      params.initiatorSkillTitle,
      params.partnerSkillId,
      params.partnerSkillTitle,
      params.duration,
      params.frequency,
      params.sessionsCount,
      params.notes,
    );
  }
}

class CreateAgreementParams extends Equatable {
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

  const CreateAgreementParams({
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
