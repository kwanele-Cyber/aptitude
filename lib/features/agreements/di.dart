import 'package:get_it/get_it.dart';
import 'package:myapp/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:myapp/features/agreements/data/datasources/agreement_remote_datasource_firebase.dart';
import 'package:myapp/features/agreements/data/repository/agreement_repository_impl.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/accept_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/cancel_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/create_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/get_agreement_by_id_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/modify_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/view_agreements_usecase.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_bloc.dart';

class AgreementDI {
  final GetIt sl;
  AgreementDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => AgreementBloc(
        createAgreementUseCase: sl(),
        acceptAgreementUseCase: sl(),
        modifyAgreementUseCase: sl(),
        cancelAgreementUseCase: sl(),
        viewAgreementsUseCase: sl(),
        getAgreementByIdUseCase: sl(),
      ),
    );

    sl.registerLazySingleton(
        () => CreateAgreementUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => AcceptAgreementUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => ModifyAgreementUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => CancelAgreementUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => ViewAgreementsUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => GetAgreementByIdUseCase(repository: sl()));

    sl.registerLazySingleton<AgreementRepository>(
      () => AgreementRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<AgreementRemoteDataSource>(
      () => AgreementRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
