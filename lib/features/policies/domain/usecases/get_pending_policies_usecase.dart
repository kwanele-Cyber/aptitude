import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/policies/domain/entities/policy_entity.dart';
import 'package:myapp/features/policies/domain/repositories/policies_repository.dart';

class GetPendingPoliciesUseCase {
  final PoliciesRepository repository;
  GetPendingPoliciesUseCase({required this.repository});

  Future<Either<Failure, List<PolicyEntity>>> call(
      GetPendingPoliciesParams params) async {
    return repository.getPendingPolicies(params.userId);
  }
}

class GetPendingPoliciesParams extends Equatable {
  final String userId;
  const GetPendingPoliciesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
