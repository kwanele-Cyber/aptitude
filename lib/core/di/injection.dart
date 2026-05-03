import 'package:get_it/get_it.dart';
import 'package:myapp/core/bloc/auth_bloc.dart';
import 'package:myapp/core/services/auth_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(authService: sl<AuthService>()));
}
