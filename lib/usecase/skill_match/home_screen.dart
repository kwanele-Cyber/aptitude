import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/usecase/auth2/auth_service.dart';
import 'package:myapp/core/utils/logger.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'discover_screen.dart';
import 'connections_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  User? _userData;
  bool _loading = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      Log.d("logged user ${user?.uid}");

      setState(() {
        if (user != null) {
          _userData = user;
        } else {
          _userData = User.fromJson({
            'firstName': '',
            'lastName': '',
            'skills': [],
            'bio': '',
            'location': AddressModel.empty().toJson(),
            'title': '',
          });
        }
        _loading = false;
      });
    } catch (e, stackTrace) {
      Log.e("Error loading user from RTDB: $e", e, stackTrace);
      setState(() {
        _userData = User.fromJson({
          'firstName': '',
          'lastName': '',
          'skills': [],
          'bio': '',
          'location': AddressModel.empty().toJson(),
          'title': '',
        });
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(
        index: _currentTab,
        children: [
          DiscoverScreen(userData: _userData!),
          const ConnectionsScreen(),
          ProfileScreen(userData: _userData!),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF7C3AED),
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Connections',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
