import 'package:get_it/get_it.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource_firebase.dart';
import 'package:myapp/features/disputes/data/repository/dispute_repository_impl.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/appeal_decision_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/create_dispute_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/report_user_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/resolve_dispute_usecase.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';

class DisputeDI {
  final GetIt sl;
  DisputeDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => DisputeBloc(
        reportUserUseCase: sl(),
        createDisputeUseCase: sl(),
        resolveDisputeUseCase: sl(),
        appealDecisionUseCase: sl(),
        disputeRepository: sl(),
      ),
    );

    sl.registerLazySingleton(() => ReportUserUseCase(repository: sl()));
    sl.registerLazySingleton(() => CreateDisputeUseCase(repository: sl()));
    sl.registerLazySingleton(() => ResolveDisputeUseCase(repository: sl()));
    sl.registerLazySingleton(() => AppealDecisionUseCase(repository: sl()));

    sl.registerLazySingleton<DisputeRepository>(
      () => DisputeRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<DisputeRemoteDataSource>(
      () => DisputeRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
