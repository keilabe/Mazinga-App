import 'package:flutter/material.dart';

class RecommendationsPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _RecommendationsPageState();

  }
}

class _RecommendationsPageState extends State<RecommendationsPage> {

  //User preferences
  String _selectedGoal = 'Weight Loss';
  String _selectedActivityType = 'Cardio';

  //List of recommendations
  final List<Map<String, dynamic>> _allRecommendations = [
    {
      'goal': 'Weight Loss',
      'type': 'Cardio',
      'activity': 'Running',
      'duration': '30 mins',
      'intensity': 'Moderate',
    },
    {
      'goal': 'Weight Loss',
      'type': 'Cardio',
      'activity': 'Cycling',
      'duration': '45 mins',
      'intensity': 'High',
    },
    {
      'goal': 'Muscle Gain',
      'type': 'Strength Training',
      'activity': 'Weight Lifting',
      'duration': '60 mins',
      'intensity': 'High',
    },
    {
      'goal': 'Muscle Gaiin',
      'type': 'Strength Training',
      'activity': 'Push-ups',
      'duration': '20 mins',
      'intensity': 'Moderate',
    },
    {
      'goal': 'Endurance',
      'type': 'Cardio',
      'activity': 'Swimming',
      'duration': '45 mins',
      'intensity': 'High',
    },
    {
      'goal': 'Endurance',
      'type': 'Flexibility',
      'activity': 'Yoga',
      'duration': '30 mins',
      'intensity': 'Low',
    },
  ];

  //Filtered recommendations based on user input
  List<Map<String, dynamic>> _filteredRecommendations = [];

  @override
  void initState() {
    super.initState();
    _filterRecommendations();
  }

  void _filterRecommendations() {
    setState(() {
      _filteredRecommendations = _allRecommendations
           .where((rec) => 
               rec['goal'] == _selectedGoal && rec['type'] == _selectedActivityType)
            .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FItness Recommendations"
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Goal Selection
            _buildDropdown(
              label: "Fitness Goal",
              value: _selectedGoal,
              items: ['Weight Loss', 'Muscle Gain', 'Endurance'],
            ),
            //Activity Type Selection
            _buildDropdown(
            label: "Activity Type",
              value: _selectedActivityType,
              items: ['Cardio', 'Strength Training', 'Flexibility'],
            ),

            //Recommendation List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRecommendations.length,
                itemBuilder: (context, index){
                  final rec = _filteredRecommendations[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        rec['activity']
                      ),
                      subtitle: Text(
                        "${rec['duration']} . ${rec['intensity']} intensity",                        
                      ),
                      trailing: Icon(Icons.fitness_center),
                    ),
                  );
            },
          ),
        ),
      ],
    ),
  ),        
);
}

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,    
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold),),
            DropdownButton<String>(
              value: value,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                  );
              }).toList(), 
              onChanged: (String? newValue) {
                setState(() {
                  value = newValue!;
                  _filterRecommendations();
                });
              },
              isExpanded: true,)
          ],
        ),
      ),      
    );
  }
}