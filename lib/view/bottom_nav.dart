import 'package:flutter/material.dart';
import 'package:taskova/auth/logout.dart';
import 'package:taskova/view/job_post.dart';
import 'package:taskova/view/profile.dart';

class HomePageWithBottomNav extends StatefulWidget {
  const HomePageWithBottomNav({Key? key}) : super(key: key);

  @override
  State<HomePageWithBottomNav> createState() => _HomePageWithBottomNavState();
}

class _HomePageWithBottomNavState extends State<HomePageWithBottomNav> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    DriverJobPostingPage(businessId: 3),
    ProfilePage(),
    // SettingsPage(),
  ];

  // On tap handler
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
