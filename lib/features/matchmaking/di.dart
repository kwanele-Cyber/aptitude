import 'package:get_it/get_it.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource_firebase.dart';
import 'package:myapp/features/matchmaking/data/repository/match_repository_impl.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/fetch_match_history_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/generate_matches_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/save_match_usecase.dart' show SaveMatchUseCase;
import 'package:myapp/features/matchmaking/domain/usecases/submit_match_feedback_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/update_match_status_usecase.dart';
import 'package:myapp/features/matchmaking/presentation/bloc/match_bloc.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource_firebase.dart';
import 'package:myapp/features/skills/data/repository/skill_repository_impl.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/archive_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_saved_search_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_saved_searches_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_user_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/filter_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/restore_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/save_search_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/search_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/submit_skill_verification_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/suggest_skill_category_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';

class MatchMakingDI{
  GetIt sl = GetIt.instance;
  MatchMakingDI(GetIt sl);

  GetIt Init(){
    
  // Matchmaking
  sl.registerFactory(() => MatchBloc(
        generateMatchesUseCase: sl(),
        updateMatchStatusUseCase: sl(),
        saveMatchUseCase: sl(),
        fetchMatchHistoryUseCase: sl(),
        submitMatchFeedbackUseCase: sl(),
      ));

  sl.registerLazySingleton(() => GenerateMatchesUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateMatchStatusUseCase(repository: sl()));
  sl.registerLazySingleton(() => SaveMatchUseCase(repository: sl()));
  sl.registerLazySingleton(() => FetchMatchHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => SubmitMatchFeedbackUseCase(repository: sl()));

  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MatchRemoteDataSource>(
    () => MatchRemoteDataSourceFirebase(),
  );
    return sl;
  }
}