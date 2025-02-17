import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data for quick stats
  int stepsToday = 4500;
  int caloriesBurned = 300;
  double waterIntake = 1.5; // in liters
  double waterGoal = 2.0; // in liters

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fitness Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Text("Good Morning, User", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Stay on track with your fitness goals!", style: TextStyle(fontSize: 16, color: Colors.grey)),

            // Quick Stats Overview
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Steps", "$stepsToday/10,000"),
                _buildStatCard("Calories", "$caloriesBurned kcal"),
                _buildStatCard("Water", "$waterIntake/$waterGoal L"),
              ],
            ),

            // Call-to-Action Buttons
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Daily Activity Input Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyActivityInputPage()),
                      );
                    },
                    child: Text("Log Activity"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Progress Tracking Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgressTrackingPage()),
                    );
                  },
                  child: Text("Track Progress"),
                ),
              ],
            ),

            // Progress Visualization
            SizedBox(height: 20),
            _buildProgressBar("Fitness Goal", 0.75),

            // Daily Activity Overview (example of items)
            SizedBox(height: 20),
            Text("Today's Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildActivityItem("Exercise: Jogging (30 minutes)", 1.0),
            _buildActivityItem("Meal: Breakfast (400 kcal)", 0.8),
            _buildActivityItem("Sleep: 7 hours", 0.9),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (index) {
          // Handle navigation to respective pages
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyActivityInputPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProgressTrackingPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FunToolsPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
      ],
    );
  }

  Widget _buildActivityItem(String activity, double completion) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(activity, style: TextStyle(fontSize: 16)),
        LinearProgressIndicator(value: completion, minHeight: 5),
      ],
    );
  }
}
