import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/usecase/auth2/change_password_screen.dart';
import 'package:myapp/usecase/auth2/login_screen.dart';
import 'package:myapp/usecase/auth2/register_screen.dart';
import 'package:myapp/usecase/auth2/forgot_password_screen.dart';
import 'package:myapp/usecase/chat/chat_screen.dart';
import 'package:myapp/usecase/dashboard/role_dashboard_gate.dart';
import 'package:myapp/usecase/landing_page/view/landing_page.dart';
import 'package:myapp/usecase/profile/profile_screen.dart';
import 'package:myapp/usecase/skill_match/create_skill_offer_screen.dart';
import 'package:myapp/usecase/skill_match/create_skill_request_screen.dart';
import 'package:myapp/usecase/skill_match/edit_skill_screen.dart';
import 'package:myapp/usecase/skill_match/match_history_screen.dart';
import 'package:myapp/usecase/skill_match/skill_details_screen.dart';
import 'package:myapp/usecase/profile/public_profile_screen.dart';
import 'package:myapp/usecase/notifications/notification_screen.dart';
import 'package:myapp/usecase/profile/blocked_users_screen.dart';
import 'package:myapp/usecase/auth2/two_factor_setup_screen.dart';
import 'package:myapp/usecase/profile/data_export_screen.dart';
import 'package:myapp/usecase/splash/splash_screen.dart';
import 'package:myapp/usecase/skill_match/home_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/changepassword',
        builder: (context, state) => ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const RoleDashboardGate(),
      ),
      GoRoute(
        path: '/auth/profile',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>?;
          if (userData == null) {
            return const Scaffold(
              body: Center(child: Text('No user data provided')),
            );
          }
          return ProfileScreen(userData: userData as User);
        },
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final peerName = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatScreen(
            channelId: state.pathParameters['chatId']!,
            peerName: peerName,
          );
        },
      ),
      GoRoute(
        path: '/skill/add',
        builder: (context, state) => const CreateSkillOfferScreen(),
      ),
      GoRoute(
        path: '/skill/request',
        builder: (context, state) => const CreateSkillRequestScreen(),
      ),
      GoRoute(
        path: '/skill/edit/:type/:id',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final id = state.pathParameters['id']!;
          return EditSkillScreen(id: id, isOffer: type == 'offer');
        },
      ),
      GoRoute(
        path: '/match-history',
        builder: (context, state) => const MatchHistoryScreen(),
      ),
      GoRoute(
        path: '/skill/:id',
        builder: (context, state) {
          final sid = state.pathParameters['id']!;
          final skillName = state.uri.queryParameters['name'];
          return SkillDetailsScreen(sid: sid, skillName: skillName);
        },
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return PublicProfileScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/profile/blocked',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/profile/2fa',
        builder: (context, state) {
          final userData = state.extra as User?;
          if (userData == null) {
            return const Scaffold(body: Center(child: Text('User data required')));
          }
          return TwoFactorSetupScreen(userData: userData);
        },
      ),
      GoRoute(
        path: '/profile/export',
        builder: (context, state) => const DataExportScreen(),
      ),
    ],
  );
}

final GoRouter router = createRouter();
