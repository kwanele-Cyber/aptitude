import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/policies/domain/entities/policy_entity.dart';
import 'package:myapp/features/policies/domain/entities/policy_acknowledgment_entity.dart';

abstract class PoliciesRepository {
  Future<Either<Failure, List<PolicyEntity>>> getPendingPolicies(
      String userId);
  Future<Either<Failure, void>> acknowledgePolicy(
      String userId, String policyId, String version);
  Future<Either<Failure, List<PolicyAcknowledgmentEntity>>>
      getAcknowledgments(String userId);
}
