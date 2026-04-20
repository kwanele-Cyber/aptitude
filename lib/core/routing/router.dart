import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/usecase/auth/service/user_registration_service.dart';
import 'package:myapp/usecase/auth/view/login_page.dart';
import 'package:myapp/usecase/auth/view/login_view_model.dart';
import 'package:myapp/usecase/auth/view/register_page.dart';
import 'package:myapp/usecase/auth/view/register_view_model.dart';
import 'package:myapp/usecase/chatsystem/screens/chat_screen.dart';
import 'package:myapp/usecase/landing_page/view/landing_page.dart';

final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LandingPage();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: LoginPage(),
        );
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return ChangeNotifierProvider(  
          create: (_) => RegisterViewModel(getUserServices()),
          child: RegisterPage(),
        );
      },
    ),
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        return ChatScreen(chatId: state.pathParameters['chatId']!);
      },
    ),
  ],
);


UserRegistrationService getUserServices() {
  return UserRegistrationService(getUserRepository());
}

UserRepository getUserRepository(){
  return UserRepository(
    databaseService: FirebaseService()
  );
}
