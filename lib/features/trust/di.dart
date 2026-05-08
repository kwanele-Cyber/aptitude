import 'package:get_it/get_it.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource_firebase.dart';
import 'package:myapp/features/trust/data/repository/trust_repository_impl.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';
import 'package:myapp/features/trust/domain/usecases/appeal_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/calculate_trust_score_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/filter_by_trust_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/get_trust_profile_usecase.dart';
import 'package:myapp/features/trust/domain/usecases/update_reputation_usecase.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_bloc.dart';

class TrustDI {
  final GetIt sl;
  TrustDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => TrustBloc(
        calculateTrustScoreUseCase: sl(),
        updateReputationUseCase: sl(),
        filterByTrustUseCase: sl(),
        getTrustProfileUseCase: sl(),
        appealTrustScoreUseCase: sl(),
        getAppealsUseCase: sl(),
      ),
    );

    sl.registerLazySingleton(
        () => CalculateTrustScoreUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => UpdateReputationUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => FilterByTrustUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => GetTrustProfileUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => AppealTrustScoreUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => GetAppealsUseCase(repository: sl()));

    sl.registerLazySingleton<TrustRepository>(
      () => TrustRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<TrustRemoteDataSource>(
      () => TrustRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
