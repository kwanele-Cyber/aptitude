import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/admin/view/pages/admin_dashboard_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/usecase/auth/view/pages/registration_page.dart';
import 'package:myapp/usecase/auth/view/pages/login_page.dart';
import 'package:myapp/usecase/auth/view/pages/profile_page.dart';
import 'package:myapp/usecase/profile/view/pages/public_profile_page.dart';
import 'package:myapp/usecase/skills/view/pages/create_skill_offer_page.dart';
import 'package:myapp/usecase/skills/view/pages/create_skill_request_page.dart';
import 'package:myapp/usecase/skills/view/pages/edit_skill_page.dart';
import 'package:myapp/usecase/discovery/view/pages/search_page.dart';
import 'package:myapp/usecase/discovery/view/pages/skill_detail_page.dart';

import 'package:myapp/core/view/widgets/main_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Public Routes
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationPage(),
    ),

    // Authenticated Shell
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
          redirect: (context, state) {
            final authViewModel = context.read<AuthViewModel>();
            if (!authViewModel.isAdmin) return '/search';
            return null;
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/:uid',
          builder: (context, state) =>
              PublicProfilePage(uid: state.pathParameters['uid']!),
        ),
        GoRoute(
          path: '/skills/create-offer',
          builder: (context, state) => const CreateSkillOfferPage(),
        ),
        GoRoute(
          path: '/skills/create-request',
          builder: (context, state) => const CreateSkillRequestPage(),
        ),
        GoRoute(
          path: '/skills/edit',
          builder: (context, state) {
            final skill = state.extra as SkillModel;
            return EditSkillPage(skill: skill);
          },
        ),
        GoRoute(
          path: '/skills/details',
          builder: (context, state) {
            final skill = state.extra as SkillModel;
            return SkillDetailPage(skill: skill);
          },
        ),
      ],
    ),
  ],
);
