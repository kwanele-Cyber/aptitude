import 'package:get_it/get_it.dart';
import 'package:myapp/features/policies/data/datasources/policies_remote_datasource.dart';
import 'package:myapp/features/policies/data/datasources/policies_remote_datasource_firebase.dart';
import 'package:myapp/features/policies/data/repository/policies_repository_impl.dart';
import 'package:myapp/features/policies/domain/repositories/policies_repository.dart';
import 'package:myapp/features/policies/domain/usecases/acknowledge_policy_usecase.dart';
import 'package:myapp/features/policies/domain/usecases/get_pending_policies_usecase.dart';
import 'package:myapp/features/policies/presentation/bloc/policies_bloc.dart';

class PoliciesDI {
  final GetIt sl;
  PoliciesDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => PoliciesBloc(
        getPendingPolicies: sl(),
        acknowledgePolicy: sl(),
      ),
    );

    sl.registerLazySingleton(
        () => GetPendingPoliciesUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => AcknowledgePolicyUseCase(repository: sl()));

    sl.registerLazySingleton<PoliciesRepository>(
      () => PoliciesRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<PoliciesRemoteDataSource>(
      () => PoliciesRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
