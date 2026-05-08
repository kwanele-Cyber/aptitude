import 'package:equatable/equatable.dart';
import 'package:myapp/features/policies/domain/entities/policy_entity.dart';

abstract class PoliciesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PoliciesInitial extends PoliciesState {}

class PoliciesLoading extends PoliciesState {}

class PoliciesLoaded extends PoliciesState {
  final List<PolicyEntity> pendingPolicies;
  final List<String> acknowledgingIds;

  PoliciesLoaded({
    required this.pendingPolicies,
    this.acknowledgingIds = const [],
  });

  @override
  List<Object?> get props => [pendingPolicies, acknowledgingIds];
}

class PoliciesError extends PoliciesState {
  final String message;
  PoliciesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PoliciesAcknowledgeSuccess extends PoliciesState {
  final String policyId;
  PoliciesAcknowledgeSuccess({required this.policyId});

  @override
  List<Object?> get props => [policyId];
}
