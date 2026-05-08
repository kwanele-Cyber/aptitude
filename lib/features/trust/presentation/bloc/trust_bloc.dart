import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/logger/logger.dart';
import 'package:myapp/features/trust/domain/usecases/appeal_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/calculate_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/filter_by_trust_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/get_trust_profile_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/update_reputation_usecase.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_event.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_state.dart';

class TrustBloc extends Bloc<TrustEvent, TrustState> {
  final CalculateTrustScoreUseCase calculateTrustScoreUseCase;
  final UpdateReputationUseCase updateReputationUseCase;
  final FilterByTrustUseCase filterByTrustUseCase;
  final GetTrustProfileUseCase getTrustProfileUseCase;
  final AppealTrustScoreUseCase appealTrustScoreUseCase;
  final GetAppealsUseCase getAppealsUseCase;

  final Logger _logger = Logger('TrustBloc');

  TrustBloc({
    required this.calculateTrustScoreUseCase,
    required this.updateReputationUseCase,
    required this.filterByTrustUseCase,
    required this.getTrustProfileUseCase,
    required this.appealTrustScoreUseCase,
    required this.getAppealsUseCase,
  }) : super(TrustInitial()) {
    on<CalculateTrustScoreRequested>(_onCalculateTrustScoreRequested);
    on<UpdateReputationRequested>(_onUpdateReputationRequested);
    on<FilterByTrustRequested>(_onFilterByTrustRequested);
    on<GetTrustProfileRequested>(_onGetTrustProfileRequested);
    on<SubmitAppealRequested>(_onSubmitAppealRequested);
    on<GetAppealsRequested>(_onGetAppealsRequested);
  }

  void _onCalculateTrustScoreRequested(
    CalculateTrustScoreRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result = await calculateTrustScoreUseCase(
      CalculateTrustScoreParams(userId: event.userId),
    );
    result.fold(
      (failure) {
        _logger.error('Failed to calculate trust score', failure.message);
        emit(TrustError(
            message: failure.message ?? 'Failed to calculate trust score'));
      },
      (trust) => emit(TrustScoreLoaded(trust: trust)),
    );
  }

  void _onUpdateReputationRequested(
    UpdateReputationRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result = await updateReputationUseCase(
      UpdateReputationParams(
        userId: event.userId,
        event: event.event,
        data: event.data,
      ),
    );
    result.fold(
      (failure) {
        _logger.error('Failed to update reputation', failure.message);
        emit(TrustError(
            message: failure.message ?? 'Failed to update reputation'));
      },
      (trust) => emit(TrustScoreLoaded(trust: trust)),
    );
  }

  void _onFilterByTrustRequested(
    FilterByTrustRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result =
        await filterByTrustUseCase(FilterByTrustParams(threshold: event.threshold));
    result.fold(
      (failure) {
        _logger.error('Failed to filter by trust', failure.message);
        emit(TrustError(
            message: failure.message ?? 'Failed to filter by trust'));
      },
      (userIds) => emit(TrustFilteredUsersLoaded(
        userIds: userIds,
        threshold: event.threshold,
      )),
    );
  }

  void _onGetTrustProfileRequested(
    GetTrustProfileRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result = await getTrustProfileUseCase(
      GetTrustProfileParams(userId: event.userId),
    );
    result.fold(
      (failure) {
        _logger.error('Failed to get trust profile', failure.message);
        emit(TrustError(
            message: failure.message ?? 'Failed to load trust profile'));
      },
      (profile) => emit(TrustProfileLoaded(profile: profile)),
    );
  }

  void _onSubmitAppealRequested(
    SubmitAppealRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result = await appealTrustScoreUseCase(
      AppealTrustScoreParams(
        userId: event.userId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) {
        _logger.error('Failed to submit appeal', failure.message);
        emit(
            TrustError(message: failure.message ?? 'Failed to submit appeal'));
      },
      (appeal) => emit(AppealSubmitted(appeal: appeal)),
    );
  }

  void _onGetAppealsRequested(
    GetAppealsRequested event,
    Emitter<TrustState> emit,
  ) async {
    emit(TrustLoading());
    final result =
        await getAppealsUseCase(GetAppealsParams(userId: event.userId));
    result.fold(
      (failure) {
        _logger.error('Failed to get appeals', failure.message);
        emit(TrustError(
            message: failure.message ?? 'Failed to load appeals'));
      },
      (appeals) => emit(AppealsLoaded(appeals: appeals)),
    );
  }
}
