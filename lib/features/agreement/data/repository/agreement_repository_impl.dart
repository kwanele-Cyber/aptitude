import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/lib/features/agreement/data/datasources/agreement_remote_datasource.dart';
import 'package:myapp/lib/features/agreement/data/models/agreement_model.dart';
import 'package:myapp/lib/features/agreement/domain/entity/agreement_entity.dart';
import 'package:myapp/lib/features/agreement/domain/repository/agreement_repository.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  final AgreementRemoteDataSource remoteDataSource;

  AgreementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AgreementEntity>> createAgreement(AgreementEntity agreement) async {
    try {
      final model = AgreementModel(
        id: agreement.id,
        initiatorId: agreement.initiatorId,
        partnerId: agreement.partnerId,
        skillId: agreement.skillId,
        skillName: agreement.skillName,
        initiatorRole: agreement.initiatorRole,
        partnerRole: agreement.partnerRole,
        durationWeeks: agreement.durationWeeks,
        sessionsPerWeek: agreement.sessionsPerWeek,
        preferredDays: agreement.preferredDays,
        format: agreement.format,
        location: agreement.location,
        materialsNeeded: agreement.materialsNeeded,
        notes: agreement.notes,
        status: agreement.status,
        createdAt: agreement.createdAt,
      );
      final created = await remoteDataSource.createAgreement(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create agreement: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> getAgreement(String id) async {
    try {
      final agreement = await remoteDataSource.getAgreement(id);
      return Right(agreement);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load agreement: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AgreementEntity>>> getUserAgreements(String userId) async {
    try {
      final agreements = await remoteDataSource.getUserAgreements(userId);
      return Right(agreements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load agreements: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AgreementEntity>>> getActiveAgreements(String userId) async {
    final result = await getUserAgreements(userId);
    return result.fold(
      (failure) => Left(failure),
      (agreements) {
        final active = agreements.where((a) => a.isActive || a.isPending).toList();
        return Right(active);
      },
    );
  }

  @override
  Future<Either<Failure, AgreementEntity>> acceptAgreement(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': AgreementStatus.active.name,
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to accept agreement: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> declineAgreement(String id, {String? reason}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': AgreementStatus.declined.name,
        'cancelledAt': now,
        'cancellationReason': reason ?? 'Declined by partner',
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to decline agreement: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> proposeModifications(
    String id,
    Map<String, dynamic> modifications,
    String notes,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updates = {
        ...modifications,
        'status': AgreementStatus.modified.name,
        'modificationNotes': notes,
        'updatedAt': now,
      };
      final updated = await remoteDataSource.updateAgreement(id, updates);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to propose modifications: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> acceptModifications(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': AgreementStatus.active.name,
        'modificationNotes': null,
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to accept modifications: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> declineModifications(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      // Revert to previous state (pending or active)
      final agreement = await remoteDataSource.getAgreement(id);
      final previousStatus = agreement.status == AgreementStatus.modified 
          ? AgreementStatus.pending 
          : agreement.status;
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': previousStatus.name,
        'modificationNotes': null,
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to decline modifications: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> cancelAgreement(String id, String reason) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': AgreementStatus.cancelled.name,
        'cancelledAt': now,
        'cancellationReason': reason,
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel agreement: $e'));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> completeAgreement(String id) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updated = await remoteDataSource.updateAgreement(id, {
        'status': AgreementStatus.completed.name,
        'completedAt': now,
        'updatedAt': now,
      });
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete agreement: $e'));
    }
  }

  @override
  Stream<Either<Failure, AgreementEntity>> watchAgreement(String id) {
    return remoteDataSource.watchAgreement(id).map((agreement) => Right<Failure, AgreementEntity>(agreement))
        .handleError((error) => Left<Failure, AgreementEntity>(ServerFailure(error.toString())));
  }

  @override
  Stream<Either<Failure, List<AgreementEntity>>> watchUserAgreements(String userId) {
    return remoteDataSource.watchUserAgreements(userId).map(
      (agreements) => Right<Failure, List<AgreementEntity>>(agreements)
    ).handleError(
      (error) => Left<Failure, List<AgreementEntity>>(ServerFailure(error.toString()))
    );
  }
}