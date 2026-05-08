import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/ai/domain/usecases/analyze_behavior_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/get_skill_recommendations_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/optimize_matches_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/predict_session_quality_usecase.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final GetSkillRecommendationsUseCase getSkillRecommendationsUseCase;
  final AnalyzeBehaviorUseCase analyzeBehaviorUseCase;
  final OptimizeMatchesUseCase optimizeMatchesUseCase;
  final PredictSessionQualityUseCase predictSessionQualityUseCase;

  AiBloc({
    required this.getSkillRecommendationsUseCase,
    required this.analyzeBehaviorUseCase,
    required this.optimizeMatchesUseCase,
    required this.predictSessionQualityUseCase,
  }) : super(AiInitial()) {
    on<GetSkillRecommendations>(_onGetSkillRecommendations);
    on<AnalyzeUserBehavior>(_onAnalyzeUserBehavior);
    on<GetMatchOptimizations>(_onGetMatchOptimizations);
    on<PredictSessionQuality>(_onPredictSessionQuality);
  }

  Future<void> _onGetSkillRecommendations(
    GetSkillRecommendations event,
    Emitter<AiState> emit,
  ) async {
    emit(AiLoading());
    final result = await getSkillRecommendationsUseCase(
      GetSkillRecommendationsParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(AiError(message: 'Failed to get skill recommendations'));
      },
      (right) async {
        emit(SkillRecommendationsLoaded(recommendations: right));
      },
    );
  }

  Future<void> _onAnalyzeUserBehavior(
    AnalyzeUserBehavior event,
    Emitter<AiState> emit,
  ) async {
    emit(AiLoading());
    final result = await analyzeBehaviorUseCase(
      AnalyzeBehaviorParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(AiError(message: 'Failed to analyze behavior'));
      },
      (right) async {
        emit(BehaviorAnalysisLoaded(flags: right));
      },
    );
  }

  Future<void> _onGetMatchOptimizations(
    GetMatchOptimizations event,
    Emitter<AiState> emit,
  ) async {
    emit(AiLoading());
    final result = await optimizeMatchesUseCase(
      OptimizeMatchesParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(AiError(message: 'Failed to get match optimizations'));
      },
      (right) async {
        emit(MatchOptimizationsLoaded(optimizations: right));
      },
    );
  }

  Future<void> _onPredictSessionQuality(
    PredictSessionQuality event,
    Emitter<AiState> emit,
  ) async {
    emit(AiLoading());
    final result = await predictSessionQualityUseCase(
      PredictSessionQualityParams(matchId: event.matchId),
    );

    await result.fold(
      (left) async {
        emit(AiError(message: 'Failed to predict session quality'));
      },
      (right) async {
        emit(SessionPredictionLoaded(prediction: right));
      },
    );
  }
}
