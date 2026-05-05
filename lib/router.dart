import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_seed_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_analytics_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_audit_log_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_broadcast_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_category_management_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_content_moderation_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_database_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_penalties_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_role_management_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_system_config_page.dart';
import 'package:myapp/features/admin/presentation/pages/admin_user_management_page.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/auth/presentation/pages/change_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/home_page.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';
import 'package:myapp/features/auth/presentation/pages/export_data_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/pages/create_skill_offer_page.dart';
import 'package:myapp/features/auth/presentation/pages/register_page.dart';
import 'package:myapp/features/auth/presentation/pages/two_factor_setup_page.dart';
import 'package:myapp/features/auth/presentation/pages/account_recovery_page.dart';
import 'package:myapp/features/auth/presentation/pages/recovery_codes_page.dart';
import 'package:myapp/features/auth/presentation/pages/two_factor_verification_page.dart';
import 'package:myapp/features/auth/presentation/pages/user_profile_page.dart';
import 'package:myapp/features/skills/presentation/pages/edit_skill_page.dart';
import 'package:myapp/features/skills/presentation/pages/browse_skills_feed_page.dart';
import 'package:myapp/features/skills/presentation/pages/search_skills_page.dart';
import 'package:myapp/features/skills/presentation/pages/skill_details_page.dart';
import 'package:myapp/features/skills/presentation/pages/filter_skills_page.dart';
import 'package:myapp/features/matchmaking/presentation/pages/match_history_page.dart';
import 'package:myapp/features/matchmaking/presentation/pages/matchmaking_page.dart';
import 'package:myapp/features/skills/presentation/pages/saved_searches_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  static const _publicRoutes = <String>{
    '/',
    '/login',
    '/register',
    '/forgot-password',
  };

  static const _adminRoutes = <String>{
    '/admin',
    '/admin/users',
    '/admin/moderation',
    '/admin/penalties',
    '/admin/analytics',
    '/admin/config',
    '/admin/categories',
    '/admin/broadcast',
    '/admin/audit',
    '/admin/roles',
    '/admin/database',
    '/admin/seed',
  };

  GoRouter get router => GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      // Don't redirect while auth is being checked
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isPublicRoute = _publicRoutes.contains(location);

      if (authState is AuthUnauthenticated || authState is AuthError) {
        //if on root route and not loggedin, redirect to login
        if (location == '/') {
          return '/login';
        }
        //default behavior for unauthenticated users: allow access to public routes, redirect to login for everything else
        return isPublicRoute ? null : '/login';
      }

      if (authState is AuthRequires2FA) {
        final verifyPath = '/2fa-verify/${authState.uid}';
        return location != verifyPath ? verifyPath : null;
      }

      if (authState is AuthAuthenticated) {
        final isAdmin = authState.userEntity.isAdmin;
        final isOnAdminRoute = _adminRoutes.contains(location);
        final isOnPublicRoute = _publicRoutes.contains(location);

        // Admin on user-only route -> redirect to /admin
        if (isAdmin && !isOnAdminRoute && !isOnPublicRoute) {
          return '/admin';
        }

        // Regular user on admin route -> redirect to /home
        if (!isAdmin && isOnAdminRoute) {
          return '/home';
        }

        // Authenticated user on login or 2FA verify -> redirect to dashboard
        if (location == '/login' || location.startsWith('/2fa-verify')) {
          return isAdmin ? '/admin' : '/home';
        }

        if (location == '/') {
          return isAdmin ? '/admin' : '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) =>
            UserProfilePage(uid: state.pathParameters['uid'] ?? ''),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => ChangePasswordPage(),
      ),
      GoRoute(
        path: '/2fa-setup',
        builder: (context, state) => TwoFactorSetupPage(),
      ),
      GoRoute(
        path: '/2fa-verify/:uid',
        builder: (context, state) =>
            TwoFactorVerificationPage(uid: state.pathParameters['uid'] ?? ''),
      ),
      GoRoute(
        path: '/recovery-codes',
        builder: (context, state) => const RecoveryCodesPage(),
      ),
      GoRoute(
        path: '/export-data',
        builder: (context, state) => const ExportDataPage(),
      ),
      GoRoute(
        path: '/skills/create',
        builder: (context, state) => const CreateSkillOfferPage(),
      ),
      GoRoute(
        path: '/skills/create-request',
        builder: (context, state) =>
            const CreateSkillOfferPage(type: SkillType.request),
      ),
      GoRoute(
        path: '/skills/edit',
        builder: (context, state) =>
            EditSkillPage(skill: state.extra as SkillEntity),
      ),
      GoRoute(
        path: '/skills/feed',
        builder: (context, state) => const BrowseSkillsFeedPage(),
      ),
      GoRoute(
        path: '/skills/details/:id',
        builder: (context, state) =>
            SkillDetailsPage(skillId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/skills/search',
        builder: (context, state) => const SearchSkillsPage(),
      ),
      GoRoute(
        path: '/skills/filter',
        builder: (context, state) => const FilterSkillsPage(),
      ),
      GoRoute(
        path: '/skills/saved-searches/:uid',
        builder: (context, state) =>
            SavedSearchesPage(uid: state.pathParameters['uid'] ?? ''),
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MatchmakingPage(),
      ),
      GoRoute(
        path: '/matches/history/:uid',
        builder: (context, state) =>
            MatchHistoryPage(userId: state.pathParameters['uid'] ?? ''),
      ),
      GoRoute(
        path: '/account-recovery',
        builder: (context, state) => const AccountRecoveryPage(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementPage(),
      ),
      GoRoute(
        path: '/admin/moderation',
        builder: (context, state) => const AdminContentModerationPage(),
      ),
      GoRoute(
        path: '/admin/penalties',
        builder: (context, state) => const AdminPenaltiesPage(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsPage(),
      ),
      GoRoute(
        path: '/admin/config',
        builder: (context, state) => const AdminSystemConfigPage(),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoryManagementPage(),
      ),
      GoRoute(
        path: '/admin/broadcast',
        builder: (context, state) => const AdminBroadcastPage(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AdminAuditLogPage(),
      ),
      GoRoute(
        path: '/admin/roles',
        builder: (context, state) => const AdminRoleManagementPage(),
      ),
      GoRoute(
        path: '/admin/database',
        builder: (context, state) => const AdminDatabasePage(),
      ),
      GoRoute(
        path: '/admin/seed',
        builder: (context, state) => const AdminSeedPage(),
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
