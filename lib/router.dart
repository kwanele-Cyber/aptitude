import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/presentation/pages/change_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/home_page.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';
import 'package:myapp/features/auth/presentation/pages/register_page.dart';
import 'package:myapp/features/auth/presentation/pages/splash_page.dart';
import 'package:myapp/features/auth/presentation/pages/two_factor_setup_page.dart';
import 'package:myapp/features/auth/presentation/pages/account_recovery_page.dart';
import 'package:myapp/features/auth/presentation/pages/recovery_codes_page.dart';
import 'package:myapp/features/auth/presentation/pages/two_factor_verification_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  static const _publicRoutes = <String>{
    '/splash',
    '/login',
    '/register',
    '/forgot-password',
  };

  GoRouter get router => GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      final isPublicRoute = _publicRoutes.contains(location);

      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isPublicRoute ? null : '/login';
      }

      if (authState is AuthAuthenticated) {
        if (location == '/login' || location == '/splash') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => ForgotPasswordPage()),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(path: '/change-password', builder: (context, state) => ChangePasswordPage()),
      GoRoute(path: '/2fa-setup', builder: (context, state) => TwoFactorSetupPage()),
      GoRoute(
        path: '/2fa-verify/:uid',
        builder: (context, state) => TwoFactorVerificationPage(
          uid: state.pathParameters['uid'] ?? '',
        ),
      ),
      GoRoute(
        path: '/recovery-codes',
        builder: (context, state) => const RecoveryCodesPage(),
      ),
      GoRoute(
        path: '/account-recovery',
        builder: (context, state) => const AccountRecoveryPage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;
}
