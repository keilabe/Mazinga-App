import 'package:fitness_tracking_app/helpers/database_helper.dart';
import 'package:fitness_tracking_app/models/fitness_day_data.dart';
import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String? userEmail;
  HomePage({Key? key, this.userEmail}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalCalories = 0;
  double totalWater = 0;
  int exerciseCount = 0;
  double waterGoal = 2.0; // Water goal in liters
  String userName = "User";
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isLoading = false;
  List<FlSpot> _chartData = []; // Stores chart data points
  // int _selectedIndex = 0;
  // final List<Widget> Pages = [
  //   HomePage(),
  //   DailyActivityInputPage(),
  //   ProgressTrackingPage(),
  //   FunToolsPage(),
  //   SettingsPage(),
  //   UserProfilePage(),
  // ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      if (widget.userEmail == null || widget.userEmail!.isEmpty) {
        print("No user email provided");
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic>? user = await dbHelper.getUserByEmail(widget.userEmail!);
      if (user != null) {
        setState(() {
          userName = user['username'] ?? "User";
        });
        await _loadTodaysSummary();
      } else {
        print("No logged-in user found");
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadTodaysSummary() async {
  try {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final activities = await dbHelper.getActivityByDate(today); // Get only today's data

    double totalCaloriesTemp = 0;
    double totalWaterTemp = 0;
    int exerciseCountTemp = 0;
    List<FlSpot> chartSpots = [];

    // Track time-based data
    List<double> hourlyCalories = List.generate(24, (_) => 0);

    for (var activity in activities) {
      // Sum totals
      totalCaloriesTemp += activity['calories'] ?? 0;
      totalWaterTemp += activity['water'] ?? 0;
      if (activity['exercise']?.isNotEmpty ?? false) exerciseCountTemp++;

      // Parse activity time
      DateTime time = DateTime.parse(activity['date']);
      hourlyCalories[time.hour] += activity['calories'] ?? 0;
    }

    // Generate chart data
    for (int hour = 0; hour < 24; hour++) {
      chartSpots.add(FlSpot(hour.toDouble(), hourlyCalories[hour]));
    }

    setState(() {
      totalCalories = totalCaloriesTemp;
      totalWater = totalWaterTemp;
      exerciseCount = exerciseCountTemp;
      _chartData = chartSpots;
    });
  } catch (e) {
    print("Error loading data: $e");
  }
}

  Widget _buildChart() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: DatabaseHelper().getActivities(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: Text("Loading..."));
      }

      if (snapshot.data!.isEmpty) {
        return Center(child: Text("No data available"));
      }

      // Convert database data to chart data points
      List<FitnessDayData> fitnessData = snapshot.data!.map((row) {
        return FitnessDayData(
          date: DateTime.parse(row['date']),
          calories: row['calories'] as double,
          exerciseMinutes: row['exercise'] != null ? 
            (row['exercise'] as String).length.toDouble() : 0.0,
          waterGlasses: row['water'] as double,
          sleepHours: row['sleep'] as double,
        );
      }).toList();

      // Prepare data points for each metric
      List<FlSpot> caloriesSpots = fitnessData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.calories);
      }).toList();

      List<FlSpot> exerciseSpots = fitnessData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.exerciseMinutes);
      }).toList();

      List<FlSpot> waterSpots = fitnessData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.waterGlasses);
      }).toList();

      List<FlSpot> sleepSpots = fitnessData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.sleepHours);
      }).toList();

      return SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, _) => 
                      Text(DateFormat('MM/dd').format(
                          fitnessData[value.toInt()].date)),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, _) => 
                      Text(value.toStringAsFixed(0)),
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: caloriesSpots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: exerciseSpots,
                isCurved: true,
                color: Colors.green,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: waterSpots,
                isCurved: true,
                color: Colors.purple,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: sleepSpots,
                isCurved: true,
                color: Colors.red,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fitness Tracker"), actions: [
        IconButton(icon: Icon(Icons.refresh), onPressed: _loadUserData),
      ]),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Good Morning, $userName",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Stay on track with your fitness goals!",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),

                    // Stats Section
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard("Workouts", "$exerciseCount sessions"),
                          _buildStatCard("Calories", "${totalCalories.toInt()} kcal"),
                          _buildStatCard("Water", "${totalWater.toStringAsFixed(1)}/$waterGoal L"),
                        ],
                      ),
                    ),

                    // Progress Chart
                    SizedBox(height: 20),
                    Text("Progress Chart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildChart(),

                    // Call-to-Action Buttons
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DailyActivityInputPage()));
                          },
                          child: Text("Log Activity"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressTrackingPage()));
                          },
                          child: Text("Track Progress"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      // bottomNavigationBar: _bottomNavigationBar(),      
    );
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
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Widget _bottomNavigationBar() {
  //   return BottomNavigationBar(
  //     currentIndex: _selectedIndex,
  //     onTap: (_index){
  //       setState(() {
  //         _selectedIndex = _index;

  //         //Navigates to the selected page
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => Pages[_index]),
  //         );
  //       });
  //     },
  //     items: [
  //         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //         BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
  //         BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
  //         BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
  //         BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
  //         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  //       ],
  //   );
  // }
}
