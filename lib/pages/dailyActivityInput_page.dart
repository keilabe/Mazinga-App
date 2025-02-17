import 'package:fitness_tracking_app/helpers/database_helper.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For formatting dates


class DailyActivityInputPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DailyActivityInputPageState();
  }
}

class _DailyActivityInputPageState extends State<DailyActivityInputPage> {
  final TextEditingController _exerciseController = TextEditingController();  
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();

  double _totalCalories = 0.0;
  double _totalWater = 0.0;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  String _currentDate = '';
  int _currentIndex = 0;

  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = _dateFormat.format(DateTime.now());
    _loadActivities();
  }

    Future<void> _loadActivities() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    try {
      List<Map<String, dynamic>> result = await dbHelper.getTodayActivities();
      setState(() {
        _activities = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log Daily Activities"),
        actions: [
          IconButton(
          icon: Icon(Icons.history_outlined), 
          onPressed: () {},         
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInputSection(
              title: "Exercise",
              hint: "e.g., Running, 30 mins",
              controller: _exerciseController,
              onSubmitted: (value) => _logActivity("exercise", value),
            ),    
            _buildInputSection(
              title: "Calories Consumed",
              hint: "Enter calories",
              controller: _caloriesController,
              onSubmitted: (value) {
                _totalCalories += double.parse(value);
                setState(() {});
              },
            ),               
            _buildInputSection(
              title: "Water (Glasses)",
              hint: "Enter glasses",
              controller: _waterController,
              onSubmitted: (value) {
                _totalWater += double.parse(value);
                setState(() {});
              }
            ),              
            _buildInputSection(
              title: "Sleep (Hours)",
              hint: "Enter hours slept",
              controller: _sleepController,
              onSubmitted: (value) => _logActivity("sleep", value),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  Text("Today's Totals", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTotalChip("Calories", "$_totalCalories kcal"),
                      _buildTotalChip("Water", "$_totalWater glasses"),
                    ],
                  ),
                ]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleSaveActivity(),
              child: Text("Save Activity"),
            ),
          ],
        ),
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
  Widget page = DailyActivityInputPage(); // Default assignment
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

    Widget _buildActivitiesSection() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_activities.isEmpty) {
      return Center(child: Text('No activities logged yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Activities",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> activity = _activities[index];
              return ListTile(
                title: Text(activity['type']),
                subtitle: Text('Value: ${activity['value']}'),
                trailing: Text(activity['date']),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection({String? title, String? hint, TextEditingController? controller, Function? onSubmitted}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title!, 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint),
              keyboardType: TextInputType.number,
              onSubmitted: (value) => onSubmitted!(value),              
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _logActivity(String type, String value) async {
    Map<String, dynamic> activity = {
      'type': type,
      'value': value,
      'date': DateTime.now().toString(),
    };

    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertActivity(activity);

    setState(() {
      _activities.add(activity);
    });

    _clearFields();    
  }

    void _clearFields() {
    _exerciseController.clear();
    _caloriesController.clear();
    _waterController.clear();
    _sleepController.clear();
  }

  Future<void> _saveDailyActivity() async {
    // Saves the user's input data
    Map<String, dynamic> activityData = {
      'date': _currentDate,
      'exercise': _exerciseController.text,
      'calories': _totalCalories,
      'water': _totalWater,
      'sleep': double.parse(_sleepController.text),
    };

    try {
      await DatabaseHelper().insertActivity(activityData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Activity logged successfully")));
      setState(() {
        // Resets fields after saving
        _exerciseController.clear();
        _caloriesController.clear();
        _waterController.clear();
        _sleepController.clear();
        _totalCalories = 0;
        _totalWater = 0;
      });
    } catch (e) {
      print("Error saving activity: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to log activity")));
    }
  }

  void _handleSaveActivity() async {
  await _saveDailyActivity();
  // Navigate to HomePage after saving the data
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
}
}
