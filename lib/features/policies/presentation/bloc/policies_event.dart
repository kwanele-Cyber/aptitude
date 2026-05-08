import 'package:equatable/equatable.dart';

abstract class PoliciesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPendingPoliciesRequested extends PoliciesEvent {
  final String userId;
  GetPendingPoliciesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AcknowledgePolicyRequested extends PoliciesEvent {
  final String userId;
  final String policyId;
  final String version;

  AcknowledgePolicyRequested({
    required this.userId,
    required this.policyId,
    required this.version,
  });

  @override
  List<Object?> get props => [userId, policyId, version];
}
