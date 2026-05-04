import 'package:equatable/equatable.dart';

abstract class MatchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMatchesRequested extends MatchEvent {
  final String userId;

  FetchMatchesRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AcceptMatchRequested extends MatchEvent {
  final String matchId;

  AcceptMatchRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class RejectMatchRequested extends MatchEvent {
  final String matchId;

  RejectMatchRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class IgnoreMatchRequested extends MatchEvent {
  final String matchId;

  IgnoreMatchRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class SaveMatchRequested extends MatchEvent {
  final String matchId;

  SaveMatchRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class FetchMatchHistoryRequested extends MatchEvent {
  final String userId;

  FetchMatchHistoryRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubmitFeedbackRequested extends MatchEvent {
  final String matchId;
  final int rating;
  final String? comment;

  SubmitFeedbackRequested({
    required this.matchId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [matchId, rating, comment];
}
