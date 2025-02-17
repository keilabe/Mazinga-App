import 'package:fitness_tracking_app/helpers/database_helper.dart';
import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProgressTrackingPageState();
  }
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  String _selectedSort = "date"; // Default sorting by date
  int _currentIndex = 0;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    final dbHelper = DatabaseHelper();
    final result = await dbHelper.getActivities();
    setState(() => _activities = result);
  }

  @override
  Widget build(BuildContext context) {
    _activities.sort((a, b) {
      if (_selectedSort == "date") {
        return a["date"].compareTo(b["date"]);
      } else if (_selectedSort == "calories") {
        return b["calories"].compareTo(a["calories"]);
      } else {
        return b["duration"].compareTo(a["duration"]);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking Progress"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButton<String>(
            value: _selectedSort,
            items: ["date", "calories", "duration"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text("Sort by ${value}"),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedSort = value!),
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: true),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _activities
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                            entry.key.toDouble(),
                            (entry.value['calories'] ?? 0).toDouble()))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text("${_activities[index]["date"]}"),
                    subtitle: Text(
                        "${_activities[index]["calories"]} kcal . ${_activities[index]["duration"]} mins"),
                    trailing: Icon(Icons.trending_up),
                  ),
                );
              },
            ),
          )
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          Widget page = ProgressTrackingPage();
          setState(() {
            _currentIndex = index;
          });
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
                MaterialPageRoute(builder: (context) => DailyActivityInputPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProgressTrackingPage()),
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
