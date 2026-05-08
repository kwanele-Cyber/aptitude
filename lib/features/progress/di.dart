import 'package:get_it/get_it.dart';
import 'package:myapp/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:myapp/features/progress/data/datasources/progress_remote_datasource_firebase.dart';
import 'package:myapp/features/progress/data/repository/progress_repository_impl.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_goals_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/set_goal_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/share_achievement_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/track_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/update_goal_progress_usecase.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_bloc.dart';

class ProgressDI {
  final GetIt sl;
  ProgressDI(this.sl);

  void Init() {
    // Data source
    sl.registerLazySingleton<ProgressRemoteDataSource>(
      () => ProgressRemoteDataSourceFirebase(),
    );

    // Repository
    sl.registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(remoteDataSource: sl<ProgressRemoteDataSource>()),
    );

    // Use cases
    sl.registerLazySingleton(() => TrackProgressUseCase(repository: sl<ProgressRepository>()));
    sl.registerLazySingleton(() => FetchProgressUseCase(repository: sl<ProgressRepository>()));
    sl.registerLazySingleton(() => SetGoalUseCase(repository: sl<ProgressRepository>()));
    sl.registerLazySingleton(() => FetchGoalsUseCase(repository: sl<ProgressRepository>()));
    sl.registerLazySingleton(() => UpdateGoalProgressUseCase(repository: sl<ProgressRepository>()));
    sl.registerLazySingleton(() => ShareAchievementUseCase(repository: sl<ProgressRepository>()));

    // Bloc
    sl.registerFactory(() => ProgressBloc(
      trackProgressUseCase: sl<TrackProgressUseCase>(),
      fetchProgressUseCase: sl<FetchProgressUseCase>(),
      setGoalUseCase: sl<SetGoalUseCase>(),
      fetchGoalsUseCase: sl<FetchGoalsUseCase>(),
      updateGoalProgressUseCase: sl<UpdateGoalProgressUseCase>(),
      shareAchievementUseCase: sl<ShareAchievementUseCase>(),
    ));
  }
}
