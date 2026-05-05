import 'package:get_it/get_it.dart';
import 'package:myapp/core/seeder/seeder_service.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource_firebase.dart';
import 'package:myapp/features/admin/data/repository/admin_repository_impl.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';
import 'package:myapp/features/admin/domain/usecases/admin_usecases.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource_firebase.dart';
import 'package:myapp/features/auth/data/repository/auth_repository_impl.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';
import 'package:myapp/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/export_user_data_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/generate_recovery_codes_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/recover_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource_firebase.dart';
import 'package:myapp/features/matchmaking/data/repository/match_repository_impl.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/fetch_match_history_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/generate_matches_usecase.dart';
import 'package:myapp/features/matchmaking/domain/usecases/save_match_usecase.dart';
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
import 'package:myapp/features/skills/domain/usecases/suggest_skill_category_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/submit_skill_verification_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  // Admin
  sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceFirebase());
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => SuspendUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => BulkUserActionUseCase(sl()));
  sl.registerLazySingleton(() => GetFlaggedContentUseCase(sl()));
  sl.registerLazySingleton(() => DismissFlagUseCase(sl()));
  sl.registerLazySingleton(() => RemoveContentUseCase(sl()));
  sl.registerLazySingleton(() => BulkModerationUseCase(sl()));
  sl.registerLazySingleton(() => GetPenaltiesUseCase(sl()));
  sl.registerLazySingleton(() => ApplyPenaltyUseCase(sl()));
  sl.registerLazySingleton(() => OverturnPenaltyUseCase(sl()));
  sl.registerLazySingleton(() => GetAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetConfigUseCase(sl()));
  sl.registerLazySingleton(() => SaveConfigUseCase(sl()));
  sl.registerLazySingleton(() => RestoreDefaultConfigUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => ReorderCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetBroadcastsUseCase(sl()));
  sl.registerLazySingleton(() => SendBroadcastUseCase(sl()));
  sl.registerLazySingleton(() => GetAuditLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetRolesUseCase(sl()));
  sl.registerLazySingleton(() => CreateRoleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRoleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRoleUseCase(sl()));
  sl.registerLazySingleton(() => GetDatabaseStatsUseCase(sl()));
  sl.registerLazySingleton(() => RunBackupUseCase(sl()));
  sl.registerLazySingleton(() => RestoreBackupUseCase(sl()));
  sl.registerLazySingleton(() => RunMaintenanceUseCase(sl()));
  sl.registerLazySingleton(() => SeederService());
  sl.registerFactory(
    () => AdminBloc(
      seederService: sl(),
      getDashboardData: sl(),
      getUsers: sl(),
      searchUsers: sl(),
      suspendUser: sl(),
      deleteUser: sl(),
      bulkUserAction: sl(),
      getFlaggedContent: sl(),
      dismissFlag: sl(),
      removeContent: sl(),
      bulkModeration: sl(),
      getPenalties: sl(),
      applyPenalty: sl(),
      overturnPenalty: sl(),
      getAnalytics: sl(),
      getConfig: sl(),
      saveConfig: sl(),
      restoreConfig: sl(),
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      reorderCategories: sl(),
      getBroadcasts: sl(),
      sendBroadcast: sl(),
      getAuditLogs: sl(),
      getRoles: sl(),
      createRole: sl(),
      updateRole: sl(),
      deleteRole: sl(),
      getDatabaseStats: sl(),
      runBackup: sl(),
      restoreBackup: sl(),
      runMaintenance: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUsecase: sl(),
      checkAuthUsecase: sl(),
      resetPasswordUseCase: sl(),
      updatePasswordUseCase: sl(),
      changePasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
      resendVerificationEmailUseCase: sl(),
      verify2FAUseCase: sl(),
      generateRecoveryCodesUseCase: sl(),
      recoverAccountUseCase: sl(),
      getUserProfileUseCase: sl(),
      exportUserDataUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(repository: sl()));
  sl.registerLazySingleton(() => CheckAuthUsecase(repository: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(repository: sl()));
  sl.registerLazySingleton(() => ResendVerificationEmailUseCase(repository: sl()));
  sl.registerLazySingleton(() => Verify2FAUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUsecase(repository: sl()));
  sl.registerLazySingleton(() => GenerateRecoveryCodesUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecoverAccountUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => ExportUserDataUseCase(repository: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceFirebase(),
  );

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

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);
}
