
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/utils/logger.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/usecase/chat/view_model/chat_list_view_model.dart';
import 'discover_screen.dart';
import 'package:myapp/usecase/connections/connections_screen.dart';
import 'package:myapp/usecase/chat/chat_list_screen.dart';
import 'package:myapp/usecase/profile/profile_screen.dart';
import 'package:myapp/core/providers/notification_provider.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Aptitude',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white70),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC4899),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          DiscoverScreen(userData: _userData!),
          const ConnectionsScreen(),
          ChangeNotifierProvider(
            create: (_) => ChatListViewModel(),
            child: const ChatListScreen(),
          ),
          ProfileScreen(userData: _userData!),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Messages',
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
