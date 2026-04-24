import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;

    // We calculate the selected index based on the current location
    final String location = GoRouterState.of(context).uri.path;
    int selectedIndex = _calculateSelectedIndex(location, isAdmin);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context, isAdmin),
        backgroundColor: const Color(0xFF0F2027),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: isAdmin ? _adminItems() : _userItems(),
      ),
    );
  }

  int _calculateSelectedIndex(String location, bool isAdmin) {
    if (isAdmin) {
      if (location == '/admin') return 0;
      if (location == '/search') return 1;
      if (location == '/profile') return 2;
    } else {
      if (location == '/search') return 0;
      if (location == '/matches') return 1;
      if (location == '/agreements') return 2;
      if (location == '/profile') return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isAdmin) {
    if (isAdmin) {
      switch (index) {
        case 0: context.go('/admin'); break;
        case 1: context.go('/search'); break;
        case 2: context.go('/profile'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/search'); break;
        case 1: context.go('/matches'); break;
        case 2: context.go('/agreements'); break;
        case 3: context.go('/profile'); break;
      }
    }
  }

  List<BottomNavigationBarItem> _adminItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  List<BottomNavigationBarItem> _userItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
      BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Agreements'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }
}
