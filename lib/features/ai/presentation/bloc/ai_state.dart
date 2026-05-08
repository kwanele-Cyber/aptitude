import 'package:equatable/equatable.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';

abstract class AiState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {}

class AiLoading extends AiState {}

class SkillRecommendationsLoaded extends AiState {
  final List<SkillRecommendationEntity> recommendations;

  SkillRecommendationsLoaded({required this.recommendations});

  @override
  List<Object?> get props => [recommendations];
}

class BehaviorAnalysisLoaded extends AiState {
  final List<BehaviorFlagEntity> flags;

  BehaviorAnalysisLoaded({required this.flags});

  @override
  List<Object?> get props => [flags];
}

class MatchOptimizationsLoaded extends AiState {
  final List<MatchOptimizationEntity> optimizations;

  MatchOptimizationsLoaded({required this.optimizations});

  @override
  List<Object?> get props => [optimizations];
}

class SessionPredictionLoaded extends AiState {
  final SessionPredictionEntity prediction;

  SessionPredictionLoaded({required this.prediction});

  @override
  List<Object?> get props => [prediction];
}

class AiError extends AiState {
  final String message;

  AiError({required this.message});

  @override
  List<Object?> get props => [message];
}
