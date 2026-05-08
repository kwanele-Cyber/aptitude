import 'package:get_it/get_it.dart';
import 'package:myapp/features/rules/data/datasources/rules_remote_datasource.dart';
import 'package:myapp/features/rules/data/datasources/rules_remote_datasource_firebase.dart';
import 'package:myapp/features/rules/data/repository/rules_repository_impl.dart';
import 'package:myapp/features/rules/domain/repositories/rules_repository.dart';
import 'package:myapp/features/rules/domain/usecases/get_platform_rules_usecase.dart';
import 'package:myapp/features/rules/presentation/bloc/rules_bloc.dart';

class RulesDI {
  final GetIt sl;
  RulesDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => RulesBloc(getPlatformRules: sl()),
    );

    sl.registerLazySingleton(
        () => GetPlatformRulesUseCase(repository: sl()));

    sl.registerLazySingleton<RulesRepository>(
      () => RulesRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<RulesRemoteDataSource>(
      () => RulesRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
