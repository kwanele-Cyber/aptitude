import 'package:equatable/equatable.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';

abstract class MatchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchesLoaded extends MatchState {
  final List<MatchEntity> matches;

  MatchesLoaded({required this.matches});

  @override
  List<Object?> get props => [matches];
}

class MatchStatusUpdated extends MatchState {
  final String matchId;
  final MatchStatus status;

  MatchStatusUpdated({required this.matchId, required this.status});

  @override
  List<Object?> get props => [matchId, status];
}

class MatchHistoryLoaded extends MatchState {
  final List<MatchEntity> matches;

  MatchHistoryLoaded({required this.matches});

  @override
  List<Object?> get props => [matches];
}

class MatchError extends MatchState {
  final String message;

  MatchError({required this.message});

  @override
  List<Object?> get props => [message];
}
