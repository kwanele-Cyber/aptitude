import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/policies/data/datasources/policies_remote_datasource.dart';
import 'package:myapp/features/policies/domain/entities/policy_acknowledgment_entity.dart';
import 'package:myapp/features/policies/domain/entities/policy_entity.dart';
import 'package:myapp/features/policies/domain/repositories/policies_repository.dart';

class PoliciesRepositoryImpl implements PoliciesRepository {
  final PoliciesRemoteDataSource remoteDataSource;

  PoliciesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PolicyEntity>>> getPendingPolicies(
    String userId,
  ) async {
    try {
      final policies = await remoteDataSource.getPolicies();
      final acknowledgments = await remoteDataSource.getAcknowledgments(userId);
      final acknowledgedPolicyIds = acknowledgments
          .map((a) => a.policyId)
          .toSet();

      final pending = policies.where((p) {
        if (!p.requiresAcknowledgement) return false;
        final ack = acknowledgments.where((a) => a.policyId == p.id).toList();
        if (ack.isEmpty) return true;
        return ack.every((a) => a.version != p.version);
      }).toList();
      return Right(pending);
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to load pending policies. reason: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> acknowledgePolicy(
    String userId,
    String policyId,
    String version,
  ) async {
    try {
      await remoteDataSource.acknowledgePolicy(userId, policyId, version);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to acknowledge policy. reason: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<PolicyAcknowledgmentEntity>>> getAcknowledgments(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getAcknowledgments(userId);
      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to load acknowledgments. reason: ${e.toString()}',
        ),
      );
    }
  }
}
