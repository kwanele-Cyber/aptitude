import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';

abstract class AgreementRepository {
  Future<Either<Failure, AgreementEntity>> createAgreement(
    String initiatorId,
    String initiatorName,
    String partnerId,
    String partnerName,
    String initiatorSkillId,
    String initiatorSkillTitle,
    String partnerSkillId,
    String partnerSkillTitle,
    String duration,
    String frequency,
    int sessionsCount,
    String? notes,
  );

  Future<Either<Failure, void>> acceptAgreement(String agreementId, String userId);

  Future<Either<Failure, AgreementEntity>> modifyAgreement(
    String agreementId,
    String userId,
    String duration,
    String frequency,
    int sessionsCount,
    String? notes,
  );

  Future<Either<Failure, void>> cancelAgreement(String agreementId, String userId);

  Future<Either<Failure, List<AgreementEntity>>> viewAgreements(String userId);
  Future<Either<Failure, AgreementEntity>> getAgreementById(String agreementId);
}
