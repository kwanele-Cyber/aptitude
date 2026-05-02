import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth2/change_password_screen.dart';
import 'package:myapp/usecase/auth2/login_screen.dart';
import 'package:myapp/usecase/auth2/register_screen.dart';
import 'package:myapp/usecase/chatsystem/screens/chat_screen.dart';
import '../../usecase/skill_match/home_screen.dart';
import 'package:myapp/usecase/skill_match/profile_screen.dart';

// 🔥 ADDED (missing screens - adjust names if yours differ)
import 'package:myapp/usecase/skill_match/discover_screen.dart';
import 'package:myapp/usecase/skill_match/connections_screen.dart';

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

    // =========================
    // HOME
    // =========================
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomeScreen();
      },
    ),

    // =========================
    // PROFILE (already correct)
    // =========================
    GoRoute(
      path: '/auth/profile',
      builder: (context, state) {
        final userData = state.extra as Map<String, dynamic>?;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: Text('No user data provided')),
          );
        }

        return ProfileScreen(userData: userData);
      },
    ),

    // =========================
    // 🔥 ADDED: DISCOVER SCREEN
    // =========================
    GoRoute(
      path: '/discover',
      builder: (context, state) {
        return const DiscoverScreen(userData: {});
      },
    ),

    // =========================
    // 🔥 ADDED: CONNECTIONS SCREEN
    // =========================
    GoRoute(
      path: '/connections',
      builder: (context, state) {
        return const ConnectionsScreen();
      },
    ),

    // =========================
    // CHAT (unchanged)
    // =========================
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        return ChatScreen(chatId: state.pathParameters['chatId']!);
      },
    ),
  ],
);
