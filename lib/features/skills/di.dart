import 'package:get_it/get_it.dart';
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
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';

class SkillsDI{
  final GetIt sl;
  SkillsDI(this.sl);

  GetIt Init(){
    // Skill ecosystem
  sl.registerFactory(() => SkillBloc(
        createSkillOfferUseCase: sl(),
        updateSkillUseCase: sl(),
        deleteSkillUseCase: sl(),
        fetchUserSkillsUseCase: sl(),
        cloneSkillUseCase: sl(),
        archiveSkillUseCase: sl(),
        restoreSkillUseCase: sl(),
        searchSkillsUseCase: sl(),
        filterSkillsUseCase: sl(),
        getSkillByIdUseCase: sl(),
        saveSearchUseCase: sl(),
        fetchSavedSearchesUseCase: sl(),
        deleteSavedSearchUseCase: sl(),
        suggestSkillCategoryUseCase: sl(),
        submitSkillVerificationUseCase: sl(),
      ));

    sl.registerLazySingleton(() => CreateSkillOfferUseCase(repository: sl()));
    sl.registerLazySingleton(() => UpdateSkillUseCase(repository: sl()));
    sl.registerLazySingleton(() => DeleteSkillUseCase(repository: sl()));
    sl.registerLazySingleton(() => FetchUserSkillsUseCase(repository: sl()));
    sl.registerLazySingleton(() => CloneSkillUseCase(repository: sl()));
    sl.registerLazySingleton(() => ArchiveSkillUseCase(repository: sl()));
    sl.registerLazySingleton(() => RestoreSkillUseCase(repository: sl()));
    sl.registerLazySingleton(() => SearchSkillsUseCase(repository: sl()));
    sl.registerLazySingleton(() => FilterSkillsUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetSkillByIdUseCase(repository: sl()));
    sl.registerLazySingleton(() => SaveSearchUseCase(repository: sl()));
    sl.registerLazySingleton(() => FetchSavedSearchesUseCase(repository: sl()));
    sl.registerLazySingleton(() => DeleteSavedSearchUseCase(repository: sl()));
    sl.registerLazySingleton(() => SuggestSkillCategoryUseCase());
    sl.registerLazySingleton(() => SubmitSkillVerificationUseCase(repository: sl()));

    sl.registerLazySingleton<SkillRepository>(
      () => SkillRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<SkillRemoteDataSource>(
      () => SkillRemoteDataSourceFirebase(),
    );
    return sl;
  }
}