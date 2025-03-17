import 'package:flutter/material.dart';
import 'package:fitness_tracking_app/helpers/database_helper.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    try {
      List<Map<String, dynamic>> result = await dbHelper.getActivities();
      setState(() {
        _activities = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        _isLoading = false;
        // You might want to show an error message here
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity History')),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_activities.isEmpty) {
      return Center(child: Text('No activities logged yet.'));
    }

    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> activity = _activities[index];
        return ListTile(
          title: Text(activity['type']),
          subtitle: Text('Value: ${activity['value']}'),
          trailing: Text(activity['date']),
        );
      },
    );
  }
}