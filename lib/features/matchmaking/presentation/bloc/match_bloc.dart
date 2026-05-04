import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/usecases/fetch_match_history_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/generate_matches_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/save_match_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/update_match_status_usecase.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_event.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final GenerateMatchesUseCase generateMatchesUseCase;
  final UpdateMatchStatusUseCase updateMatchStatusUseCase;
  final SaveMatchUseCase saveMatchUseCase;
  final FetchMatchHistoryUseCase fetchMatchHistoryUseCase;

  MatchBloc({
    required this.generateMatchesUseCase,
    required this.updateMatchStatusUseCase,
    required this.saveMatchUseCase,
    required this.fetchMatchHistoryUseCase,
  }) : super(MatchInitial()) {
    on<FetchMatchesRequested>(_onFetchMatchesRequested);
    on<AcceptMatchRequested>(_onAcceptMatchRequested);
    on<RejectMatchRequested>(_onRejectMatchRequested);
    on<IgnoreMatchRequested>(_onIgnoreMatchRequested);
    on<SaveMatchRequested>(_onSaveMatchRequested);
    on<FetchMatchHistoryRequested>(_onFetchMatchHistoryRequested);
  }

  Future _onFetchMatchesRequested(
    FetchMatchesRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await generateMatchesUseCase(
      GenerateMatchesParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to fetch matches'));
      },
      (right) async {
        emit(MatchesLoaded(matches: right));
      },
    );
  }

  Future _onAcceptMatchRequested(
    AcceptMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await updateMatchStatusUseCase(
      UpdateMatchStatusParams(
        matchId: event.matchId,
        status: MatchStatus.accepted,
      ),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to accept match'));
      },
      (right) async {
        emit(MatchStatusUpdated(
          matchId: event.matchId,
          status: MatchStatus.accepted,
        ));
      },
    );
  }

  Future _onRejectMatchRequested(
    RejectMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await updateMatchStatusUseCase(
      UpdateMatchStatusParams(
        matchId: event.matchId,
        status: MatchStatus.rejected,
      ),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to reject match'));
      },
      (right) async {
        emit(MatchStatusUpdated(
          matchId: event.matchId,
          status: MatchStatus.rejected,
        ));
      },
    );
  }

  Future _onIgnoreMatchRequested(
    IgnoreMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await updateMatchStatusUseCase(
      UpdateMatchStatusParams(
        matchId: event.matchId,
        status: MatchStatus.ignored,
      ),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to ignore match'));
      },
      (right) async {
        emit(MatchStatusUpdated(
          matchId: event.matchId,
          status: MatchStatus.ignored,
        ));
      },
    );
  }

  Future _onSaveMatchRequested(
    SaveMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await saveMatchUseCase(
      SaveMatchParams(matchId: event.matchId),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to save match'));
      },
      (right) async {
        emit(MatchStatusUpdated(
          matchId: event.matchId,
          status: MatchStatus.pending,
        ));
      },
    );
  }

  Future _onFetchMatchHistoryRequested(
    FetchMatchHistoryRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await fetchMatchHistoryUseCase(
      FetchMatchHistoryParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(MatchError(message: 'Failed to fetch match history'));
      },
      (right) async {
        emit(MatchHistoryLoaded(matches: right));
      },
    );
  }
}
