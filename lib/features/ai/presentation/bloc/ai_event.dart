import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSkillRecommendations extends AiEvent {
  final String userId;

  GetSkillRecommendations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AnalyzeUserBehavior extends AiEvent {
  final String userId;

  AnalyzeUserBehavior({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetMatchOptimizations extends AiEvent {
  final String userId;

  GetMatchOptimizations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class PredictSessionQuality extends AiEvent {
  final String matchId;

  PredictSessionQuality({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}
