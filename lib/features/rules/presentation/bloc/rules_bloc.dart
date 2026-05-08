import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/rules/domain/usecases/get_platform_rules_usecase.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_event.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_state.dart';

class RulesBloc extends Bloc<RulesEvent, RulesState> {
  final GetPlatformRulesUseCase _getPlatformRules;

  RulesBloc({required GetPlatformRulesUseCase getPlatformRules})
      : _getPlatformRules = getPlatformRules,
        super(RulesInitial()) {
    on<GetPlatformRulesRequested>(_onGetPlatformRules);
  }

  Future<void> _onGetPlatformRules(
    GetPlatformRulesRequested event,
    Emitter<RulesState> emit,
  ) async {
    emit(RulesLoading());
    final result = await _getPlatformRules.call();
    result.fold(
      (failure) {
        final msg = failure is ServerFailure
            ? failure.message ?? 'Failed to load rules.'
            : 'Failed to load rules.';
        emit(RulesError(message: msg));
      },
      (rules) => emit(RulesLoaded(rules: rules)),
    );
  }
}
