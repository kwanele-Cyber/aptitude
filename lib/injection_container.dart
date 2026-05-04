import 'package:get_it/get_it.dart';
import 'package:myapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_datasource_firebase.dart';
import 'package:myapp/features/auth/data/repository/auth_repository_impl.dart';
import 'package:myapp/features/auth/domain/repository/auth_repository.dart';
import 'package:myapp/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/export_user_data_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/generate_recovery_codes_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/recover_account_usecase.dart';
import 'package:myapp/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource_firebase.dart';
import 'package:myapp/features/skills/data/repository/skill_repository_impl.dart';
import 'package:myapp/features/skills/domain/repository/skill_repository.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_user_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  // Register dependencies here
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
  sl.registerLazySingleton(
    () => GenerateRecoveryCodesUseCase(repository: sl()),
  );
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
      ));

  sl.registerLazySingleton(() => CreateSkillOfferUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateSkillUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteSkillUseCase(repository: sl()));
  sl.registerLazySingleton(
      () => FetchUserSkillsUseCase(repository: sl()));
  sl.registerLazySingleton(() => CloneSkillUseCase(repository: sl()));

  sl.registerLazySingleton<SkillRepository>(
    () => SkillRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SkillRemoteDataSource>(
    () => SkillRemoteDataSourceFirebase(),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);
}
