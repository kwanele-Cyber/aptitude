import 'package:get_it/get_it.dart';
import 'package:myapp/core/backblaze_service.dart';
import 'package:myapp/features/admin/di.dart';
import 'package:myapp/features/agreements/di.dart';
import 'package:myapp/features/ai/di.dart';
import 'package:myapp/features/auth/di.dart';
import 'package:myapp/features/disputes/di.dart';
import 'package:myapp/features/feedback/di.dart';
import 'package:myapp/features/matchmaking/di.dart';
import 'package:myapp/features/messages/di.dart';
import 'package:myapp/features/notifications/di.dart';
import 'package:myapp/features/progress/di.dart';
import 'package:myapp/features/skills/di.dart';
import 'package:myapp/features/sessions/di.dart';
import 'package:myapp/features/trust/di.dart';
import 'package:myapp/features/rules/di.dart';
import 'package:myapp/features/policies/di.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  // Register FileStorageService backed by BackblazeB2Service
  sl.registerLazySingleton<FileStorageService>(() => BackblazeB2Service());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton(sharedPreferences);

  //inject dependecy injections from each feature
  AuthDI(sl).Init();
  AdminDI(sl).Init();
  AgreementDI(sl).Init();
  AiDI(sl).Init();
  DisputeDI(sl).Init();
  FeedbackDI(sl).Init();
  MatchMakingDI(sl).Init();
  MessagesDI(sl).Init();
  NotificationDI(sl).Init();
  ProgressDI(sl).Init();
  SkillsDI(sl).Init();
  SessionsDI(sl).Init();
  TrustDI(sl).Init();
  RulesDI(sl).Init();
  PoliciesDI(sl).Init();
}
