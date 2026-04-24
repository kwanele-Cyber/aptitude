import 'package:flutter/material.dart';
import 'package:myapp/core/repositories/auth_repository.dart';
import 'package:myapp/core/repositories/auth_repository_impl.dart';
import 'package:myapp/core/repositories/user_repository.dart';
import 'package:myapp/core/repositories/user_repository_impl.dart';
import 'package:myapp/core/repositories/skill_repository.dart';
import 'package:myapp/core/repositories/skill_repository_impl.dart';
import 'package:myapp/core/routing/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/usecase/profile/profile_viewmodel.dart';
import 'package:myapp/usecase/skills/skill_viewmodel.dart';
import 'package:myapp/usecase/discovery/discovery_viewmodel.dart';
import 'package:myapp/usecase/discovery/skill_detail_viewmodel.dart';
import 'package:myapp/core/repositories/match_repository.dart';
import 'package:myapp/core/repositories/chat_repository.dart';
import 'package:myapp/core/repositories/agreement_repository.dart';
import 'package:myapp/core/repositories/admin_repository.dart';
import 'package:myapp/core/repositories/session_repository.dart';
import 'package:myapp/usecase/admin/admin_viewmodel.dart';
import 'package:myapp/core/services/location_service.dart';
import 'package:myapp/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl();
  final userRepository = UserRepositoryImpl();
  final skillRepository = SkillRepositoryImpl();
  final agreementRepository = AgreementRepositoryImpl();
  final locationService = LocationService();
  final matchRepository = MatchRepositoryImpl(
    skillRepository,
    userRepository,
    locationService,
  );
  final chatRepository = ChatRepositoryImpl();
  final adminRepository = AdminRepositoryImpl();
  final sessionRepository = SessionRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<SkillRepository>.value(value: skillRepository),
        Provider<MatchRepository>.value(value: matchRepository),
        Provider<ChatRepository>.value(value: chatRepository),
        Provider<AgreementRepository>.value(value: agreementRepository),
        Provider<AdminRepository>.value(value: adminRepository),
        Provider<SessionRepository>.value(value: sessionRepository),
        Provider<LocationService>.value(value: locationService),

        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository, locationService),
        ),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(userRepository)),
        ChangeNotifierProvider(create: (_) => SkillViewModel(skillRepository)),
        ChangeNotifierProvider(
          create: (_) => DiscoveryViewModel(skillRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SkillDetailViewModel(userRepository),
        ),
        ChangeNotifierProvider(create: (_) => AdminViewModel(adminRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router, title: 'Flutter MVVM');
  }
}
