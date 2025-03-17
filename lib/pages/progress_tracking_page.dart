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
  String _selectedSort = "date";
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _activities = [];
  final List<Widget> Pages = [
    HomePage(),
    DailyActivityInputPage(),
    ProgressTrackingPage(),
    FunToolsPage(),
    SettingsPage(),
    UserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    final dbHelper = DatabaseHelper();
    final result = await dbHelper.getActivities();
    print("Fetched Activities: $result");  // Debugging output
    setState(() => _activities = List<Map<String, dynamic>>.from(result));
  }

  @override
  Widget build(BuildContext context) {
    // Sort activities safely
    List<Map<String, dynamic>> sortedActivities = [..._activities];
    sortedActivities.sort((a, b) {
        final dateA = a["date"] ?? "";
        final dateB = b["date"] ?? "";
        final caloriesA = a["calories"] ?? 0;
        final caloriesB = b["calories"] ?? 0;
        final durationA = a["duration"] ?? 0;
        final durationB = b["duration"] ?? 0;

      if (_selectedSort == "date") {
        return (a["date"] ?? "").compareTo(b["date"] ?? "");
      } else if (_selectedSort == "calories") {
        return (b["calories"] ?? 0).compareTo(a["calories"] ?? 0);
      } else {
        return (b["duration"] ?? 0).compareTo(a["duration"] ?? 0);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking Progress"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
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
    titlesData: FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
          axisNameWidget: Text("Total calories (kcal)", style: TextStyle(fontSize: 12)),
          sideTitles: SideTitles(
            showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(value.toString(), style: TextStyle(fontSize: 12));
           },
          ),
        ),
        rightTitles: AxisTitles(
          axisNameWidget: Text("Total calories (kcal)", style: TextStyle(fontSize: 12)),
          sideTitles: SideTitles(showTitles: false),
        ),
         bottomTitles: AxisTitles(
             axisNameWidget: Text("Date", style: TextStyle(fontSize: 12)),
              sideTitles: SideTitles(
              showTitles: true,
               getTitlesWidget: (double value, TitleMeta meta) {
              return Text("Date", style: TextStyle(fontSize: 12));
          },
        ),
      ),
    ),
    gridData: FlGridData(show: true),
    borderData: FlBorderData(show: true),
    lineBarsData: [
      LineChartBarData(
        spots: sortedActivities
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
                itemCount: sortedActivities.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text("${sortedActivities[index]["date"]}"),
                      subtitle: Text(
                          "${sortedActivities[index]["calories"]} kcal . ${sortedActivities[index]["duration"]} mins"),
                      trailing: Icon(Icons.trending_up),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNavigationBar(),
    );
  }

//   Widget _bottomNavigationBar() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       onTap: (_index){
//         setState(() {
//           _selectedIndex = _index;

//           //Navigates to the selected page
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => Pages[_index]),
//           );
//         });
//       },
//       items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
//           BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
//           BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//     );
// }
}