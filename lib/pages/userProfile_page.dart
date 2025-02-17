import 'dart:io';

import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/helpers/database_helper.dart';
import 'progress_tracking_page.dart'; // Import the DatabaseHelper

class UserProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserProfilePageState();
  }
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _activityLevelController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _profilePicturePathController = TextEditingController();

  String _gender = 'Male';
  String _fitnessGoal = 'Maintenance';
  double _bmr = 0.0;
  bool _isMetric = true;
  File? _profileImage;
  int _currentIndex = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Calculator function for BMR
  void _calculateBMR() {
    if (_ageController.text.isEmpty || _heightController.text.isEmpty || _weightController.text.isEmpty) return;

    double weight = double.parse(_weightController.text);
    double height = double.parse(_heightController.text);
    int age = int.parse(_ageController.text);

    setState(() {
      _bmr = _gender == 'Male'
          ? 88.62 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
          : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    });
  }

  // Save profile to database
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> profile = {
        'age': int.parse(_ageController.text),
        'gender': _gender,
        'height': double.parse(_heightController.text),
        'weight': double.parse(_weightController.text),
        'fitness_goal': _fitnessGoal,
        'activity_level': _activityLevelController.text,
        'body_fat': double.parse(_bodyFatController.text),
        'profile_picture_path': _profileImage?.path ?? '',
        'bmr': _bmr,
      };

      int id = await _dbHelper.insertUserProfile(profile);
      print("Profile saved with ID: $id");
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final permanentImage = await _saveImagePermanently(image);
      setState(() => _profileImage = permanentImage);
    }
  }

  Future<File> _saveImagePermanently(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = basename(image.name);
    final permanentImage = File('${directory.path}/$fileName');
    await File(image.path).copy(permanentImage.path);
    return permanentImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildUnitToggle(),
            _buildProfileImageSection(),
            _buildProfileInputSection(),
            _buildBMRDisplay(),
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
  Widget page =UserProfilePage();
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

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(_isMetric ? 'Metric (cm, kg)' : 'Imperial (in, lbs)'),
        Switch(
          value: _isMetric,
          onChanged: (value) {
            setState(() {
              _isMetric = value;
              _calculateBMR(); // Recalculate BMR after switching units
            });
          },
        ),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : AssetImage('assets/default_avatar.png') as ImageProvider,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileInputSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Age"),
              validator: (value) => value!.isEmpty ? 'Enter age' : null,
              onChanged: (_) => _calculateBMR(),
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                  _calculateBMR();
                });
              },
              decoration: InputDecoration(labelText: "Gender"),
            ),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Height (cm)"),
              validator: (value) => value!.isEmpty ? 'Enter height' : null,
              onChanged: (_) => _calculateBMR(),
            ),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight (kg)"),
              validator: (value) => value!.isEmpty ? 'Enter weight' : null,
              onChanged: (_) => _calculateBMR(),
            ),
            TextFormField(
              controller: _bodyFatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Body Fat %"),
              onChanged: (_) => _calculateBMR(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMRDisplay() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("BMR: ${_bmr.toStringAsFixed(1)} kcal/day"),
          ],
        ),
      ),
    );
  }
}
