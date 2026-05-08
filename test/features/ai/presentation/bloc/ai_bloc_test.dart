import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/entities/skill_recommendation_entity.dart';
import 'package:myapp/features/ai/domain/usecases/analyze_behavior_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/get_skill_recommendations_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/optimize_matches_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/predict_session_quality_usecase.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_event.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockGetSkillRecommendationsUseCase extends Mock
    implements GetSkillRecommendationsUseCase {}

class MockAnalyzeBehaviorUseCase extends Mock
    implements AnalyzeBehaviorUseCase {}

class MockOptimizeMatchesUseCase extends Mock
    implements OptimizeMatchesUseCase {}

class MockPredictSessionQualityUseCase extends Mock
    implements PredictSessionQualityUseCase {}

final tRecommendation = SkillRecommendationEntity(
  id: 'rec_1',
  skillTitle: 'Data Science',
  category: 'Technology',
  reason: 'Pairs well with Python',
  confidenceScore: 0.87,
  type: RecommendationType.learn,
);

final tFlag = BehaviorFlagEntity(
  id: 'flag_1',
  userId: 'user1',
  type: FlagType.unusualLoginLocation,
  severity: FlagSeverity.high,
  description: 'Login from unusual location',
  timestamp: DateTime(2025, 1, 1),
);

final tOptimization = MatchOptimizationEntity(
  id: 'opt_1',
  metric: 'match_score_accuracy',
  currentValue: 0.72,
  suggestedValue: 0.85,
  insight: 'Including session history improves accuracy by 13%',
  impact: 'high',
);

final tPrediction = SessionPredictionEntity(
  matchId: 'match1',
  predictedQuality: 0.82,
  confidence: 0.76,
  keyFactors: [
    'complementary_skill_levels',
    'availability_overlap',
  ],
);

void main() {
  late AiBloc bloc;
  late MockGetSkillRecommendationsUseCase mockGetRecommendations;
  late MockAnalyzeBehaviorUseCase mockAnalyzeBehavior;
  late MockOptimizeMatchesUseCase mockOptimizeMatches;
  late MockPredictSessionQualityUseCase mockPredictQuality;

  setUpAll(() {
    registerFallbackValue(const GetSkillRecommendationsParams(userId: ''));
    registerFallbackValue(const AnalyzeBehaviorParams(userId: ''));
    registerFallbackValue(const OptimizeMatchesParams(userId: ''));
    registerFallbackValue(const PredictSessionQualityParams(matchId: ''));
  });

  setUp(() {
    mockGetRecommendations = MockGetSkillRecommendationsUseCase();
    mockAnalyzeBehavior = MockAnalyzeBehaviorUseCase();
    mockOptimizeMatches = MockOptimizeMatchesUseCase();
    mockPredictQuality = MockPredictSessionQualityUseCase();

    bloc = AiBloc(
      getSkillRecommendationsUseCase: mockGetRecommendations,
      analyzeBehaviorUseCase: mockAnalyzeBehavior,
      optimizeMatchesUseCase: mockOptimizeMatches,
      predictSessionQualityUseCase: mockPredictQuality,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('GetSkillRecommendations', () {
    blocTest<AiBloc, AiState>(
      'emits [AiLoading, SkillRecommendationsLoaded] on success',
      build: () {
        when(() => mockGetRecommendations(any()))
            .thenAnswer((_) async => Right([tRecommendation]));
        return bloc;
      },
      act: (bloc) => bloc.add(GetSkillRecommendations(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<SkillRecommendationsLoaded>().having(
          (s) => s.recommendations,
          'recommendations',
          [tRecommendation],
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [AiLoading, AiError] on failure',
      build: () {
        when(() => mockGetRecommendations(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetSkillRecommendations(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<AiError>(),
      ],
    );
  });

  group('AnalyzeUserBehavior', () {
    blocTest<AiBloc, AiState>(
      'emits [AiLoading, BehaviorAnalysisLoaded] on success',
      build: () {
        when(() => mockAnalyzeBehavior(any()))
            .thenAnswer((_) async => Right([tFlag]));
        return bloc;
      },
      act: (bloc) => bloc.add(AnalyzeUserBehavior(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<BehaviorAnalysisLoaded>().having(
          (s) => s.flags,
          'flags',
          [tFlag],
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [AiLoading, AiError] on failure',
      build: () {
        when(() => mockAnalyzeBehavior(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AnalyzeUserBehavior(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<AiError>(),
      ],
    );
  });

  group('GetMatchOptimizations', () {
    blocTest<AiBloc, AiState>(
      'emits [AiLoading, MatchOptimizationsLoaded] on success',
      build: () {
        when(() => mockOptimizeMatches(any()))
            .thenAnswer((_) async => Right([tOptimization]));
        return bloc;
      },
      act: (bloc) => bloc.add(GetMatchOptimizations(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<MatchOptimizationsLoaded>().having(
          (s) => s.optimizations,
          'optimizations',
          [tOptimization],
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [AiLoading, AiError] on failure',
      build: () {
        when(() => mockOptimizeMatches(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetMatchOptimizations(userId: 'user1')),
      expect: () => [
        isA<AiLoading>(),
        isA<AiError>(),
      ],
    );
  });

  group('PredictSessionQuality', () {
    blocTest<AiBloc, AiState>(
      'emits [AiLoading, SessionPredictionLoaded] on success',
      build: () {
        when(() => mockPredictQuality(any()))
            .thenAnswer((_) async => Right(tPrediction));
        return bloc;
      },
      act: (bloc) => bloc.add(PredictSessionQuality(matchId: 'match1')),
      expect: () => [
        isA<AiLoading>(),
        isA<SessionPredictionLoaded>().having(
          (s) => s.prediction,
          'prediction',
          tPrediction,
        ),
      ],
    );

    blocTest<AiBloc, AiState>(
      'emits [AiLoading, AiError] on failure',
      build: () {
        when(() => mockPredictQuality(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(PredictSessionQuality(matchId: 'match1')),
      expect: () => [
        isA<AiLoading>(),
        isA<AiError>(),
      ],
    );
  });
}
