import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/policies/domain/repositories/policies_repository.dart';

class AcknowledgePolicyUseCase {
  final PoliciesRepository repository;
  AcknowledgePolicyUseCase({required this.repository});

  Future<Either<Failure, void>> call(AcknowledgePolicyParams params) async {
    return repository.acknowledgePolicy(
        params.userId, params.policyId, params.version);
  }
}

class AcknowledgePolicyParams extends Equatable {
  final String userId;
  final String policyId;
  final String version;
  const AcknowledgePolicyParams({
    required this.userId,
    required this.policyId,
    required this.version,
  });

  @override
  List<Object?> get props => [userId, policyId, version];
}
