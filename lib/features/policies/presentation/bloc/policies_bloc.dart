import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/policies/domain/usecases/acknowledge_policy_usecase.dart';
import 'package:myapp/features/policies/domain/usecases/get_pending_policies_usecase.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_event.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_state.dart';

class PoliciesBloc extends Bloc<PoliciesEvent, PoliciesState> {
  final GetPendingPoliciesUseCase _getPendingPolicies;
  final AcknowledgePolicyUseCase _acknowledgePolicy;

  PoliciesBloc({
    required GetPendingPoliciesUseCase getPendingPolicies,
    required AcknowledgePolicyUseCase acknowledgePolicy,
  })  : _getPendingPolicies = getPendingPolicies,
        _acknowledgePolicy = acknowledgePolicy,
        super(PoliciesInitial()) {
    on<GetPendingPoliciesRequested>(_onGetPendingPolicies);
    on<AcknowledgePolicyRequested>(_onAcknowledgePolicy);
  }

  Future<void> _onGetPendingPolicies(
    GetPendingPoliciesRequested event,
    Emitter<PoliciesState> emit,
  ) async {
    emit(PoliciesLoading());
    final result = await _getPendingPolicies(
        GetPendingPoliciesParams(userId: event.userId));
    result.fold(
      (failure) {
        final msg = failure is ServerFailure
            ? failure.message ?? 'Failed to load policies.'
            : 'Failed to load policies.';
        emit(PoliciesError(message: msg));
      },
      (policies) => emit(PoliciesLoaded(pendingPolicies: policies)),
    );
  }

  Future<void> _onAcknowledgePolicy(
    AcknowledgePolicyRequested event,
    Emitter<PoliciesState> emit,
  ) async {
    final currentState = state;
    if (currentState is PoliciesLoaded) {
      emit(PoliciesLoaded(
        pendingPolicies: currentState.pendingPolicies,
        acknowledgingIds: [
          ...currentState.acknowledgingIds,
          event.policyId
        ],
      ));
    }

    final result = await _acknowledgePolicy(AcknowledgePolicyParams(
      userId: event.userId,
      policyId: event.policyId,
      version: event.version,
    ));

    result.fold(
      (failure) {
        final msg = failure is ServerFailure
            ? failure.message ?? 'Failed to acknowledge policy.'
            : 'Failed to acknowledge policy.';
        emit(PoliciesError(message: msg));
      },
      (_) {
        // After acknowledging, refresh the pending list
        add(GetPendingPoliciesRequested(userId: event.userId));
      },
    );
  }
}
