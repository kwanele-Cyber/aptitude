import 'package:flutter/material.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/usecase/dashboard/admin_dashboard_screen.dart';
import 'package:myapp/usecase/dashboard/member_dashboard_screen.dart';
import 'package:myapp/usecase/dashboard/mentor_dashboard_screen.dart';

class RoleDashboardGate extends StatelessWidget {
  const RoleDashboardGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final role = snapshot.data?.role ?? 'member';
        switch (role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'mentor':
            return const MentorDashboardScreen();
          default:
            return const MemberDashboardScreen();
        }
      },
    );
  }
}
