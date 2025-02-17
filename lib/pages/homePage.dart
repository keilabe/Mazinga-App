import 'package:fitness_tracking_app/helpers/database_helper.dart';
import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String? userEmail;

  HomePage({Key? key, this.userEmail}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Statistics tracking
  double totalCalories = 0;
  double totalWater = 0;
  int exerciseCount = 0;
  double waterGoal = 2.0; // Default goal in liters
  
  String userName = "User";
  DatabaseHelper dbHelper = DatabaseHelper();
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    
    try {
      if (widget.userEmail != null) {
        Map<String, dynamic>? user = await dbHelper.getUserByEmail(widget.userEmail!);
        
        if (user != null) {
          setState(() {
            userName = user['username'];
          });
          
          await _loadTodaysSummary();
        } else {
          print("No logged-in user found");
        }
      } else {
        print("No user email provided");
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadTodaysSummary() async {
    try {
      final activities = await dbHelper.getTodayActivities();
      
      double totalCaloriesTemp = 0;
      double totalWaterTemp = 0;
      int exerciseCountTemp = 0;

      for (var activity in activities) {
        totalCaloriesTemp += activity['calories'] ?? 0;
        totalWaterTemp += activity['water'] ?? 0;
        if (activity['exercise']?.isNotEmpty ?? false) {
          exerciseCountTemp++;
        }
      }

      setState(() {
        totalCalories = totalCaloriesTemp;
        totalWater = totalWaterTemp;
        exerciseCount = exerciseCountTemp;
      });
    } catch (e) {
      print("Error loading today's summary: $e");
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
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
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String activity, double completion) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(activity, style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: completion,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fitness Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section
                      Text(
                        "Good Morning, $userName",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Stay on track with your fitness goals!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      // Quick Stats Overview
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatCard(
                                "Workouts", "$exerciseCount sessions"),
                            _buildStatCard(
                                "Calories", "${totalCalories.toInt()} kcal"),
                            _buildStatCard(
                                "Water",
                                "${totalWater.toStringAsFixed(1)}/$waterGoal L"),
                          ],
                        ),
                      ),

                      // Call-to-Action Buttons
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DailyActivityInputPage(),
                                    ),
                                  );
                                },
                                child: Text("Log Activity"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProgressTrackingPage(),
                                    ),
                                  );
                                },
                                child: Text("Track Progress"),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Progress Visualization
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildProgressBar(
                            "Daily Fitness Goal",
                            totalCalories / 2500), // Assuming daily goal of 2500 calories
                      ),

                      // Daily Activity Overview
                      SizedBox(height: 20),
                      Text(
                        "Today's Activities",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildActivityItem(
                            "Exercise: Jogging (30 minutes)", 1.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildActivityItem(
                            "Meal: Breakfast (400 kcal)", 0.8),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildActivityItem("Sleep: 7 hours", 0.9),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_run), label: "Activity"),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(
              icon: Icon(Icons.games), label: "Fun Tools"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyActivityInputPage(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressTrackingPage(),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FunToolsPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
              break;
            case 5:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}