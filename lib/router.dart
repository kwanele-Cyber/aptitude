import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/injection_container.dart' as di;
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
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/messages/presentation/pages/chat_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';
import 'package:myapp/features/auth/domain/entity/user_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';
import 'package:myapp/features/messages/presentation/pages/room_chat_page.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/presentation/pages/create_skill_page.dart';
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
import 'package:myapp/features/notifications/presentation/pages/notification_history_page.dart';
import 'package:myapp/features/notifications/presentation/pages/notification_preferences_page.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:myapp/features/progress/presentation/pages/progress_dashboard_page.dart';
import 'package:myapp/features/progress/presentation/pages/set_goal_page.dart';
import 'package:myapp/features/agreements/presentation/pages/my_agreements_page.dart';
import 'package:myapp/features/agreements/presentation/pages/agreement_detail_page.dart';
import 'package:myapp/features/agreements/presentation/pages/create_agreement_page.dart';
import 'package:myapp/features/skills/presentation/pages/saved_searches_page.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/pages/session_detail_page.dart';
import 'package:myapp/features/sessions/presentation/pages/session_list_page.dart';
import 'package:myapp/features/sessions/presentation/pages/create_session_page.dart';
import 'package:myapp/features/disputes/presentation/pages/dispute_list_page.dart';
import 'package:myapp/features/disputes/presentation/pages/create_dispute_page.dart';
import 'package:myapp/features/disputes/presentation/pages/dispute_detail_page.dart';
import 'package:myapp/features/ai/presentation/pages/ai_hub_page.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_bloc.dart';
import 'package:myapp/features/trust/presentation/pages/trust_profile_page.dart';
import 'package:myapp/features/trust/presentation/pages/appeal_page.dart';
import 'package:myapp/features/ai/presentation/pages/skill_recommendations_page.dart';
import 'package:myapp/features/ai/presentation/pages/behavior_analysis_page.dart';
import 'package:myapp/features/ai/presentation/pages/match_optimization_page.dart';
import 'package:myapp/features/ai/presentation/pages/session_prediction_page.dart';

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
    '/admin/disputes',
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
        path: '/messages/:uid',
        builder: (context, state) {
          final extra = state.extra;
          final userName = extra is AdminUserEntity
              ? extra.name
              : extra is UserEntity
                  ? extra.name
                  : 'User';
          return ChatPage(
            userId: state.pathParameters['uid'] ?? '',
            userName: userName,
          );
        },
      ),
      GoRoute(
        path: '/rooms/:roomId',
        builder: (context, state) {
          final extra = state.extra;
          final roomArgs = extra is RoomChatArgs
              ? extra
              : RoomChatArgs(
                  room: RoomEntity(
                    id: state.pathParameters['roomId'] ?? '',
                    name: 'Room',
                    createdBy: '',
                    memberIds: const [],
                    createdAt: DateTime.now(),
                  ),
                  memberNames: const {},
                );
          return RoomChatPage(args: roomArgs);
        },
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
        builder: (context, state) => const CreateSkillPage(),
      ),
      GoRoute(
        path: '/skills/create-request',
        builder: (context, state) =>
            const CreateSkillPage(type: SkillType.request),
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
        path: '/agreements',
        builder: (context, state) => const MyAgreementsPage(),
      ),
      GoRoute(
        path: '/agreements/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return CreateAgreementPage(
            partnerId: extra?['partnerId'],
            partnerName: extra?['partnerName'],
            initiatorSkillId: extra?['initiatorSkillId'],
            initiatorSkillTitle: extra?['initiatorSkillTitle'],
            partnerSkillId: extra?['partnerSkillId'],
            partnerSkillTitle: extra?['partnerSkillTitle'],
          );
        },
      ),
      GoRoute(
        path: '/agreements/:id',
        builder: (context, state) =>
            AgreementDetailPage(agreementId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/account-recovery',
        builder: (context, state) => const AccountRecoveryPage(),
      ),

      // Progress routes
      GoRoute(
        path: '/progress',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<ProgressBloc>(),
          child: const ProgressDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/progress/goals/new',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<ProgressBloc>(),
          child: const SetGoalPage(),
        ),
      ),

      // Notification routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationHistoryPage(),
      ),
      GoRoute(
        path: '/notifications/preferences',
        builder: (context, state) => const NotificationPreferencesPage(),
      ),

      // Trust routes
      GoRoute(
        path: '/trust/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return BlocProvider(
            create: (_) => di.sl<TrustBloc>(),
            child: TrustProfilePage(userId: uid),
          );
        },
      ),
      GoRoute(
        path: '/trust/:uid/appeal',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return BlocProvider(
            create: (_) => di.sl<TrustBloc>(),
            child: AppealPage(userId: uid),
          );
        },
      ),

      // Session routes
      GoRoute(
        path: '/sessions/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return BlocProvider(
            create: (_) => di.sl<SessionBloc>(),
            child: SessionListPage(userId: uid),
          );
        },
      ),
      GoRoute(
        path: '/sessions/:uid/detail',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          final session = state.extra as SessionEntity;
          return BlocProvider(
            create: (_) => di.sl<SessionBloc>(),
            child: SessionDetailPage(session: session, userId: uid),
          );
        },
      ),
      GoRoute(
        path: '/sessions/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreateSessionPage(
            matchId: extra?['matchId'] as String? ?? '',
            skillId: extra?['skillId'] as String? ?? '',
            skillTitle: extra?['skillTitle'] as String? ?? '',
            initiatorId: extra?['initiatorId'] as String? ?? '',
            participantId: extra?['participantId'] as String? ?? '',
            participantName: extra?['participantName'] as String? ?? '',
          );
        },
      ),

      // Dispute routes
      GoRoute(
        path: '/disputes',
        builder: (context, state) => const DisputeListPage(),
      ),
      GoRoute(
        path: '/disputes/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return CreateDisputePage(
            respondentId: extra?['respondentId'],
            respondentName: extra?['respondentName'],
            agreementId: extra?['agreementId'],
            sessionId: extra?['sessionId'],
          );
        },
      ),
      GoRoute(
        path: '/disputes/:id',
        builder: (context, state) => DisputeDetailPage(
          disputeId: state.pathParameters['id'] ?? '',
        ),
      ),

      // AI Insights routes
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AiHubPage(),
      ),
      GoRoute(
        path: '/ai/recommendations',
        builder: (context, state) => const SkillRecommendationsPage(),
      ),
      GoRoute(
        path: '/ai/behavior',
        builder: (context, state) => const BehaviorAnalysisPage(),
      ),
      GoRoute(
        path: '/ai/optimization',
        builder: (context, state) => const MatchOptimizationPage(),
      ),
      GoRoute(
        path: '/ai/prediction',
        builder: (context, state) =>
            SessionPredictionPage(matchId: state.extra as String? ?? ''),
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
