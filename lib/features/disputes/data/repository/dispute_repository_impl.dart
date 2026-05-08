import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource.dart';
import 'package:myapp/features/disputes/data/models/dispute_model.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:uuid/uuid.dart';

class DisputeRepositoryImpl implements DisputeRepository {
  final DisputeRemoteDataSource remoteDataSource;

  DisputeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DisputeEntity>> reportUser({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
    required String description,
    List<String> evidenceUrls = const [],
  }) async {
    try {
      final now = DateTime.now();
      final dispute = DisputeModel(
        id: const Uuid().v4(),
        type: DisputeType.report,
        reporterId: reporterId,
        reporterName: reporterName,
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
        reason: reason,
        description: description,
        evidenceUrls: evidenceUrls,
        createdAt: now,
        updatedAt: now,
      );

      await remoteDataSource.createDispute(dispute);
      return Right(dispute);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> createDispute({
    required String reporterId,
    required String reporterName,
    required String respondentId,
    required String reason,
    required String description,
    String? agreementId,
    String? sessionId,
    List<String> evidenceUrls = const [],
  }) async {
    try {
      final now = DateTime.now();
      final dispute = DisputeModel(
        id: const Uuid().v4(),
        type: DisputeType.dispute,
        reporterId: reporterId,
        reporterName: reporterName,
        respondentId: respondentId,
        agreementId: agreementId,
        sessionId: sessionId,
        reason: reason,
        description: description,
        evidenceUrls: evidenceUrls,
        createdAt: now,
        updatedAt: now,
      );

      await remoteDataSource.createDispute(dispute);
      return Right(dispute);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> resolveDispute(
    String disputeId, {
    required String resolution,
    required String resolvedBy,
    required DisputeStatus status,
  }) async {
    try {
      final existing = await remoteDataSource.getDispute(disputeId);
      if (existing == null) {
        return Left(ServerFailure('Dispute not found'));
      }

      final now = DateTime.now();
      await remoteDataSource.updateDispute(disputeId, {
        'status': status.name,
        'resolution': resolution,
        'resolvedBy': resolvedBy,
        'resolvedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getDispute(disputeId);
      if (updated == null) {
        return Left(ServerFailure('Dispute not found after update'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> appealDecision(
    String disputeId, {
    required String appealReason,
  }) async {
    try {
      final existing = await remoteDataSource.getDispute(disputeId);
      if (existing == null) {
        return Left(ServerFailure('Dispute not found'));
      }

      if (!existing.canAppeal) {
        return Left(
            ServerFailure('This dispute cannot be appealed at this time'));
      }

      final now = DateTime.now();
      await remoteDataSource.updateDispute(disputeId, {
        'status': DisputeStatus.appealed.name,
        'appealReason': appealReason,
        'appealedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      final updated = await remoteDataSource.getDispute(disputeId);
      if (updated == null) {
        return Left(ServerFailure('Dispute not found after update'));
      }
      return Right(updated);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DisputeEntity>>> getDisputesForUser(
      String userId) async {
    try {
      final disputes = await remoteDataSource.fetchDisputesForUser(userId);
      return Right(disputes);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DisputeEntity>>> getAllDisputes() async {
    try {
      final disputes = await remoteDataSource.fetchAllDisputes();
      return Right(disputes);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> getDisputeById(
      String disputeId) async {
    try {
      final dispute = await remoteDataSource.getDispute(disputeId);
      if (dispute == null) {
        return Left(ServerFailure('Dispute not found'));
      }
      return Right(dispute);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
