import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth2/change_password_screen.dart';
import 'package:myapp/usecase/auth2/login_screen.dart';
import 'package:myapp/usecase/auth2/register_screen.dart';
import 'package:myapp/usecase/chatsystem/screens/chat_screen.dart';
import 'package:myapp/usecase/landing_page/view/landing_page.dart';
import 'package:myapp/usecase/skill_match/home_screen.dart';
import 'package:myapp/usecase/skill_match/profile_screen.dart';
import 'package:provider/provider.dart';



final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) {
        return RegisterScreen();
      },
    ),
    GoRoute(
      path: '/auth/changepassword',
      builder: (context, state) {
        return ChangePasswordScreen();
      },
    ),
    GoRoute(
      path: '/auth/forgot',
      builder: (context, state) {
        return ChangePasswordScreen();
      },
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomeScreen();
      },
    ),
    GoRoute(
      path: '/auth/profile',
      builder: (context, state) {
        // We expect userData to be passed via the 'extra' parameter
        final userData = state.extra as Map<String, dynamic>?;

        if (userData == null) {
          // Fallback or Error handling if no data is passed
          return const Scaffold(
            body: Center(child: Text('No user data provided')),
          );
        }

        return ProfileScreen(userData: userData);
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
