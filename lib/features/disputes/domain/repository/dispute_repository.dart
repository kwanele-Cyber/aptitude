import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';

abstract class DisputeRepository {
  Future<Either<Failure, DisputeEntity>> reportUser({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
    required String description,
    List<String> evidenceUrls = const [],
  });

  Future<Either<Failure, DisputeEntity>> createDispute({
    required String reporterId,
    required String reporterName,
    required String respondentId,
    required String reason,
    required String description,
    String? agreementId,
    String? sessionId,
    List<String> evidenceUrls = const [],
  });

  Future<Either<Failure, DisputeEntity>> resolveDispute(
    String disputeId, {
    required String resolution,
    required String resolvedBy,
    required DisputeStatus status,
  });

  Future<Either<Failure, DisputeEntity>> appealDecision(
    String disputeId, {
    required String appealReason,
  });

  Future<Either<Failure, List<DisputeEntity>>> getDisputesForUser(
    String userId,
  );

  Future<Either<Failure, List<DisputeEntity>>> getAllDisputes();

  Future<Either<Failure, DisputeEntity>> getDisputeById(String disputeId);
}
