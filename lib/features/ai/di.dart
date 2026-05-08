import 'package:get_it/get_it.dart';
import 'package:myapp/core/network/deepseek_client.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:myapp/features/ai/data/datasources/ai_remote_datasource_deepseek.dart';
import 'package:myapp/features/ai/data/repository/ai_repository_impl.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';
import 'package:myapp/features/ai/domain/usecases/analyze_behavior_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/get_skill_recommendations_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/optimize_matches_usecase.dart';
import 'package:myapp/features/ai/domain/usecases/predict_session_quality_usecase.dart';
import 'package:myapp/features/ai/presentation/bloc/ai_bloc.dart';

class AiDI {
  final GetIt sl;
  AiDI(this.sl);

  GetIt Init() {
    // BLoC
    sl.registerFactory(
      () => AiBloc(
        getSkillRecommendationsUseCase: sl(),
        analyzeBehaviorUseCase: sl(),
        optimizeMatchesUseCase: sl(),
        predictSessionQualityUseCase: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(
        () => GetSkillRecommendationsUseCase(repository: sl()));
    sl.registerLazySingleton(() => AnalyzeBehaviorUseCase(repository: sl()));
    sl.registerLazySingleton(() => OptimizeMatchesUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => PredictSessionQualityUseCase(repository: sl()));

    // Repository
    sl.registerLazySingleton<AiRepository>(
      () => AiRepositoryImpl(remoteDataSource: sl()),
    );

    // Data source
    sl.registerLazySingleton<DeepSeekClient>(() => DeepSeekClient());
    sl.registerLazySingleton<AiRemoteDataSource>(
      () => AiRemoteDataSourceDeepSeek(client: sl()),
    );
    return sl;
  }
}
