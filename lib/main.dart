import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/login_page.dart';
import 'package:fitness_tracking_app/pages/register_page.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isDarkTheme = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  late Future<Widget> initialPage;

  @override
  void initState() {
    super.initState();
    initialPage = _loadInitialPage();
  }

  Future<Widget> _loadInitialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Return the correct initial page based on login status
  if (isLoggedIn) {
    // Get the user email from SharedPreferences
    String? userEmail = prefs.getString('userEmail');
    if (userEmail != null) {
    return HomePage(userEmail: userEmail!);
  } else {
    print("No user email found in SharedPreferences");

    return LoginPage();
  }
  } else {
    return LoginPage();
  }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This removes the debug banner
      title: 'Mazinga App',
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder<Widget>(
        future: initialPage,  // Use FutureBuilder to handle the asynchronous initial page load
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Show loading indicator while waiting
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return snapshot.data ?? LoginPage();  // Fallback to LoginPage if no data
        },
      ),
      routes: {    
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/progress': (context) => ProgressTrackingPage(),
        '/profile': (context) => UserProfilePage(),
        '/activity': (context) => DailyActivityInputPage(),
        '/fun_tools': (context) => FunToolsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
