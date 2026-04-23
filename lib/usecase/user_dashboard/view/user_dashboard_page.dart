import 'package:flutter/material.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildProfile(),
          _buildSkills(),
          _buildMatches(),
          _buildChats(),
          _buildSettings(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Skills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return const Center(
      child: Text('Profile Page'),
    );
  }

  Widget _buildSkills() {
    return const Center(
      child: Text('Skills Page'),
    );
  }

  Widget _buildMatches() {
    return const Center(
      child: Text('Matches Page'),
    );
  }

  Widget _buildChats() {
    return const Center(
      child: Text('Chats Page'),
    );
  }

  Widget _buildSettings() {
    return const Center(
      child: Text('Settings Page'),
    );
  }
}
