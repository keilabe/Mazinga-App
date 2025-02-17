import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Variables to hold current settings values
  bool _notificationsEnabled = true;
  String _unitPreference = 'kg'; // Default unit: kg
  String _lengthPreference = 'cm'; // Default length: cm
  bool _isDarkTheme = false;

  int _currentIndex = 0;
  // List of unit options
  List<String> _unitOptions = ['kg', 'lb'];
  List<String> _lengthOptions = ['cm', 'ft'];

  // Function to toggle dark/light theme
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkTheme = value;
      // Apply the theme change to the app's theme (for example purposes, it's just a variable)
      // In a real app, you would use ThemeMode.system or ThemeData
    });
  }

  // Function to save settings (for example, save to local storage or a database)
  void _saveSettings() {
    // You can save the settings here using a persistent method like SharedPreferences, etc.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Settings saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications toggle switch
            _buildNotificationsToggle(),
            SizedBox(height: 20),
            // Unit preferences dropdown
            _buildUnitPreferenceDropdown(),
            SizedBox(height: 20),
            // Length preferences dropdown
            _buildLengthPreferenceDropdown(),
            SizedBox(height: 20),
            // Dark/Light theme switch
            _buildThemeSwitcher(),
            SizedBox(height: 20),
            // Save Button
            _buildSaveButton(),
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
  Widget page = SettingsPage();
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

  // Widget to toggle notifications on/off
  Widget _buildNotificationsToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Enable Notifications", style: TextStyle(fontSize: 18)),
        Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  // Widget for unit preference dropdown
  Widget _buildUnitPreferenceDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Select Unit (Weight)", style: TextStyle(fontSize: 18)),
        DropdownButton<String>(
          value: _unitPreference,
          onChanged: (String? newValue) {
            setState(() {
              _unitPreference = newValue!;
            });
          },
          items: _unitOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget for length preference dropdown
  Widget _buildLengthPreferenceDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Select Unit (Length)", style: TextStyle(fontSize: 18)),
        DropdownButton<String>(
          value: _lengthPreference,
          onChanged: (String? newValue) {
            setState(() {
              _lengthPreference = newValue!;
            });
          },
          items: _lengthOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget to switch between dark and light theme
  Widget _buildThemeSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Dark Theme", style: TextStyle(fontSize: 18)),
        Switch(
          value: _isDarkTheme,
          onChanged: _toggleTheme,
        ),
      ],
    );
  }

  // Save button
  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveSettings,
        child: Text("Save Settings"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
      ),
    );
  }
}
