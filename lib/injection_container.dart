import 'package:get_it/get_it.dart';
import 'package:myapp/features/admin/di.dart';
import 'package:myapp/features/auth/di.dart';
import 'package:myapp/features/matchmaking/di.dart';
import 'package:myapp/features/messages/di.dart';

import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  // Admin

  

  AuthDI(sl).Init();
  AdminDI(sl).Init();
  MatchMakingDI(sl).Init();
  MessagesDI(sl).Init();


  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);

    // Register Backblaze implementation for FileStorageService
  sl.registerLazySingleton<FileStorageService>(() => BackblazeB2Service());
}
