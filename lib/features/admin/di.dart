import 'package:get_it/get_it.dart';
import 'package:myapp/core/seeder/seeder_service.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource_firebase.dart';
import 'package:myapp/features/admin/data/repository/admin_repository_impl.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';
import 'package:myapp/features/admin/domain/usecases/admin_usecases.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';

class AdminDI {
  GetIt sl = GetIt.instance;

  AdminDI(GetIt sl);

  GetIt Init() {
    sl.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceFirebase(),
    );
    sl.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(remoteDataSource: sl()),
    );
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

    return sl;
  }
}
