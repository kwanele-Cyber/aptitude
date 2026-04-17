import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth/view/login_page.dart';
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
        return LoginPage();
      },
    ),
  ],
);
