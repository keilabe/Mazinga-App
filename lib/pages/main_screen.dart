import 'package:flutter/material.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dailyActivityInput_page.dart';
import 'funTools_page.dart';
import 'progress_tracking_page.dart';
import 'settings_page.dart';
import 'userProfile_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadInitialPage();
  }

  Future<void> _loadInitialPage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userEmail = prefs.getString('userEmail');

  setState(() {
    _isLoggedIn = isLoggedIn;
    _userEmail = userEmail;
    _isLoading = false;
  });

  if (!_isLoggedIn) {
    // Navigate to login page instead of replacing the MainScreen body
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return LoginPage();
    }

    // Pages for navigation
    List<Widget> pages = [
      HomePage(userEmail: _userEmail!),
      DailyActivityInputPage(),
      ProgressTrackingPage(),
      FunToolsPage(),
      SettingsPage(),
      UserProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
