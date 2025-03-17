import 'dart:io';

import 'package:fitness_tracking_app/pages/funTools_page.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/helpers/database_helper.dart';
import 'dailyActivityInput_page.dart';
import 'homePage.dart';


class UserProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserProfilePageState();
  }
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();  
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _activityLevelController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _profilePicturePathController = TextEditingController();  
  int _selectedIndex = 0;

  

  String _gender = 'Male';
  String _fitnessGoal = 'Maintenance';
  double _bmr = 0.0;
  bool _isMetric = true;
  File? _profileImage;  

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    try {
      final currentUser = await _dbHelper.getCurrentUser();
      if (currentUser == null) return;

      final profile = await _dbHelper.getUserProfile(currentUser['id']);
      if (profile != null) {
        if (!mounted) return;
        setState(() {
          _ageController.text = profile['age']?.toString() ?? '';
          _gender = profile['gender'] ?? 'Male';
          _heightController.text = profile['height']?.toString() ?? '';
          _weightController.text = profile['weight']?.toString() ?? '';
          _bodyFatController.text = profile['body_fat']?.toString() ?? '';
          _fitnessGoal = profile['fitness_goal'] ?? 'Maintenance';
          _activityLevelController.text = profile['activity_level'] ?? '';
          
          if (profile['profile_picture_path']?.isNotEmpty ?? false) {
            _profileImage = File(profile['profile_picture_path']);
          }
        });
        _calculateBMR();
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error loading profile: $e');
    }
  }

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

  void _convertUnits(bool toMetric) {
    if (_heightController.text.isNotEmpty) {
      double height = double.parse(_heightController.text);
      _heightController.text = toMetric 
          ? (height * 2.54).toStringAsFixed(1)  // inches to cm
          : (height / 2.54).toStringAsFixed(1); // cm to inches
    }

    if (_weightController.text.isNotEmpty) {
      double weight = double.parse(_weightController.text);
      _weightController.text = toMetric
          ? (weight * 0.453592).toStringAsFixed(1)  // lbs to kg
          : (weight / 0.453592).toStringAsFixed(1); // kg to lbs
    }
  }

  // Save profile to database
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isSaving = true);

    try {
      // Get current user
      final currentUser = await _dbHelper.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        _showMessage('Please log in to save your profile');
        return;
      }

      Map<String, dynamic> profile = {
        'user_id': currentUser['id'],
        'age': int.parse(_ageController.text),
        'gender': _gender,
        'height': double.parse(_heightController.text),
        'weight': double.parse(_weightController.text),
        'fitness_goal': _fitnessGoal,
        'activity_level': _activityLevelController.text,
        'body_fat': _bodyFatController.text.isNotEmpty 
            ? double.parse(_bodyFatController.text)
            : null,
        'profile_picture_path': _profileImage?.path ?? '',
        'bmr': _bmr,
      };

      // Check if profile exists for current user
      final existingProfile = await _dbHelper.getUserProfile(currentUser['id']);
      
      if (existingProfile != null) {
        // Update existing profile
        await _dbHelper.updateUserProfile(currentUser['id'], profile);
      } else {
        // Insert new profile
        await _dbHelper.insertUserProfile(profile);
      }

      if (!mounted) return;
      _showMessage('Profile saved successfully');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error saving profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(      
        appBar: AppBar(
          title: const Text("User Profile"),
          actions: [
            IconButton(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
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
              _convertUnits(value);
              _calculateBMR();
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
            : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileInputSection() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  errorText: _ageController.text.isNotEmpty && 
                    (int.tryParse(_ageController.text) == null || int.parse(_ageController.text) <= 0)
                    ? 'Please enter a valid age'
                    : null,
                ),
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
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isMetric ? "Height (cm)" : "Height (inches)",
                  errorText: _heightController.text.isNotEmpty && 
                    (double.tryParse(_heightController.text) == null || double.parse(_heightController.text) <= 0)
                    ? 'Please enter a valid height'
                    : null,
                ),
                validator: (value) => value!.isEmpty ? 'Enter height' : null,
                onChanged: (_) => _calculateBMR(),
              ),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isMetric ? "Weight (kg)" : "Weight (lbs)",
                  errorText: _weightController.text.isNotEmpty && 
                    (double.tryParse(_weightController.text) == null || double.parse(_weightController.text) <= 0)
                    ? 'Please enter a valid weight'
                    : null,
                ),
                validator: (value) => value!.isEmpty ? 'Enter weight' : null,
                onChanged: (_) => _calculateBMR(),
              ),
              TextFormField(
                controller: _bodyFatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Body Fat %",
                  errorText: _bodyFatController.text.isNotEmpty && 
                    (double.tryParse(_bodyFatController.text) == null || 
                     double.parse(_bodyFatController.text) < 0 || 
                     double.parse(_bodyFatController.text) > 100)
                    ? 'Please enter a valid body fat percentage (0-100)'
                    : null,
                ),
                onChanged: (_) => _calculateBMR(),
              ),
              DropdownButtonFormField<String>(
                value: _fitnessGoal,
                items: ['Weight Loss', 'Maintenance', 'Muscle Gain'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fitnessGoal = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Fitness Goal"),
              ),
              TextFormField(
                controller: _activityLevelController,
                decoration: const InputDecoration(
                  labelText: "Activity Level",
                  hintText: "e.g., Sedentary, Light, Moderate, Active, Very Active",
                ),
                validator: (value) => value!.isEmpty ? 'Enter activity level' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMRDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metabolic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BMR:'),
                Text(
                  '${_bmr.toStringAsFixed(1)} kcal/day',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Calorie Needs:'),
                Text(
                  '${(_bmr * 1.2).toStringAsFixed(1)} kcal/day',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BMI:'),
                Text(
                  _calculateBMI(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateBMI() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      return 'N/A';
    }

    double height = double.parse(_heightController.text);
    double weight = double.parse(_weightController.text);
    
    // Convert to meters if in cm
    if (_isMetric) {
      height = height / 100;
    } else {
      height = height * 0.0254; // inches to meters
    }

    double bmi = weight / (height * height);
    String category = '';

    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    return '${bmi.toStringAsFixed(1)} ($category)';
  }
}
