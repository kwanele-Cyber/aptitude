import 'package:get_it/get_it.dart';
import 'package:myapp/features/sessions/data/datasources/session_material_remote_datasource.dart';
import 'package:myapp/features/sessions/data/datasources/session_material_remote_datasource_firebase.dart';
import 'package:myapp/features/sessions/data/datasources/session_note_remote_datasource.dart';
import 'package:myapp/features/sessions/data/datasources/session_note_remote_datasource_firebase.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource.dart';
import 'package:myapp/features/sessions/data/datasources/session_remote_datasource_firebase.dart';
import 'package:myapp/features/sessions/data/repository/session_material_repository_impl.dart';
import 'package:myapp/features/sessions/data/repository/session_note_repository_impl.dart';
import 'package:myapp/features/sessions/data/repository/session_repository_impl.dart';
import 'package:myapp/features/sessions/domain/repository/session_material_repository.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/confirm_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/create_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/delete_material_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_by_id_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_materials_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_notes_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/join_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/leave_waitlist_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/complete_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/generate_verification_code_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/start_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/toggle_session_reminder_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_notes_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/upload_material_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/verify_attendance_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_bloc.dart';

class SessionsDI {
  final GetIt sl;
  SessionsDI(this.sl);

  GetIt Init() {
    // Session Bloc
    sl.registerFactory(() => SessionBloc(
          createSessionUseCase: sl(),
          updateSessionUseCase: sl(),
          cancelSessionUseCase: sl(),
          getSessionByIdUseCase: sl(),
          getUserSessionsUseCase: sl(),
          confirmSessionUseCase: sl(),
          joinWaitlistUseCase: sl(),
          leaveWaitlistUseCase: sl(),
          toggleSessionReminderUseCase: sl(),
          startSessionUseCase: sl(),
          completeSessionUseCase: sl(),
          generateVerificationCodeUseCase: sl(),
          verifyAttendanceUseCase: sl(),
        ));

    // Session Material Bloc
    sl.registerFactory(() => SessionMaterialBloc(
          uploadMaterialUseCase: sl(),
          deleteMaterialUseCase: sl(),
          getSessionMaterialsUseCase: sl(),
        ));

    // Session Note Bloc
    sl.registerFactory(() => SessionNoteBloc(
          getSessionNotesUseCase: sl(),
          updateSessionNotesUseCase: sl(),
          sessionNoteRepository: sl(),
        ));

    // Session use cases
    sl.registerLazySingleton(() => CreateSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => UpdateSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => CancelSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetSessionByIdUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetUserSessionsUseCase(repository: sl()));
    sl.registerLazySingleton(() => ConfirmSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => JoinWaitlistUseCase(repository: sl()));
    sl.registerLazySingleton(() => LeaveWaitlistUseCase(repository: sl()));
    sl.registerLazySingleton(() => ToggleSessionReminderUseCase(repository: sl()));
    sl.registerLazySingleton(() => StartSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => CompleteSessionUseCase(repository: sl()));
    sl.registerLazySingleton(() => GenerateVerificationCodeUseCase(repository: sl()));
    sl.registerLazySingleton(() => VerifyAttendanceUseCase(repository: sl()));

    // Material use cases
    sl.registerLazySingleton(() => UploadMaterialUseCase(repository: sl()));
    sl.registerLazySingleton(() => DeleteMaterialUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetSessionMaterialsUseCase(repository: sl()));

    // Note use cases
    sl.registerLazySingleton(() => GetSessionNotesUseCase(repository: sl()));
    sl.registerLazySingleton(() => UpdateSessionNotesUseCase(repository: sl()));

    // Session repository + datasource
    sl.registerLazySingleton<SessionRepository>(
      () => SessionRepositoryImpl(remoteDataSource: sl(), adminRepository: sl()),
    );
    sl.registerLazySingleton<SessionRemoteDataSource>(
      () => SessionRemoteDataSourceFirebase(),
    );

    // Session Material repository + datasource
    sl.registerLazySingleton<SessionMaterialRepository>(
      () => SessionMaterialRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<SessionMaterialRemoteDataSource>(
      () => SessionMaterialRemoteDataSourceFirebase(),
    );

    // Session Note repository + datasource
    sl.registerLazySingleton<SessionNoteRepository>(
      () => SessionNoteRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<SessionNoteRemoteDataSource>(
      () => SessionNoteRemoteDataSourceFirebase(),
    );

    return sl;
  }
}
