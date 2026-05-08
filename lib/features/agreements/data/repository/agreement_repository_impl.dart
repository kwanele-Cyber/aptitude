import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:myapp/features/agreements/data/models/agreement_model.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:uuid/uuid.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  final AgreementRemoteDataSource remoteDataSource;

  AgreementRepositoryImpl({required this.remoteDataSource});

  @override
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
  ) async {
    try {
      final now = DateTime.now();
      final agreement = AgreementModel(
        id: const Uuid().v4(),
        initiatorId: initiatorId,
        initiatorName: initiatorName,
        partnerId: partnerId,
        partnerName: partnerName,
        initiatorSkillId: initiatorSkillId,
        initiatorSkillTitle: initiatorSkillTitle,
        partnerSkillId: partnerSkillId,
        partnerSkillTitle: partnerSkillTitle,
        status: AgreementStatus.pending,
        duration: duration,
        frequency: frequency,
        sessionsCount: sessionsCount,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await remoteDataSource.createAgreement(agreement);
      return Right(agreement);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> acceptAgreement(
      String agreementId, String userId) async {
    try {
      await remoteDataSource.updateAgreement(agreementId, {
        'status': AgreementStatus.accepted.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> modifyAgreement(
    String agreementId,
    String userId,
    String duration,
    String frequency,
    int sessionsCount,
    String? notes,
  ) async {
    try {
      final now = DateTime.now();
      await remoteDataSource.updateAgreement(agreementId, {
        'status': AgreementStatus.modified.name,
        'duration': duration,
        'frequency': frequency,
        'sessionsCount': sessionsCount,
        'notes': notes,
        'modifiedBy': userId,
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getAgreement(agreementId);
      if (updated == null) {
        return Left(ServerFailure('Agreement not found after update'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelAgreement(
      String agreementId, String userId) async {
    try {
      await remoteDataSource.updateAgreement(agreementId, {
        'status': AgreementStatus.cancelled.name,
        'cancelledBy': userId,
        'cancelledAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AgreementEntity>>> viewAgreements(
      String userId) async {
    try {
      final agreements =
          await remoteDataSource.fetchAgreementsForUser(userId);
      return Right(agreements);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> getAgreementById(
      String agreementId) async {
    try {
      final agreement = await remoteDataSource.getAgreement(agreementId);
      if (agreement == null) {
        return Left(ServerFailure('Agreement not found'));
      }
      return Right(agreement);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
