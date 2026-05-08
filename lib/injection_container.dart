import 'package:get_it/get_it.dart';
import 'package:myapp/core/backblaze_service.dart';
import 'package:myapp/features/admin/di.dart';
import 'package:myapp/features/auth/di.dart';
import 'package:myapp/features/matchmaking/di.dart';
import 'package:myapp/features/messages/di.dart';
import 'package:myapp/features/skills/di.dart';

import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  // Register FileStorageService backed by BackblazeB2Service
  sl.registerLazySingleton<FileStorageService>(() => BackblazeB2Service());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);

  

  AuthDI(sl).Init();
  AdminDI(sl).Init();
  MatchMakingDI(sl).Init();
  MessagesDI(sl).Init();
  SkillsDI(sl).Init();

}
