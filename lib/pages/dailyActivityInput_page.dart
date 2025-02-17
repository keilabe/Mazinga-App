import 'package:flutter/material.dart';

class DailyActivityInputPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _DailyActivityInputPageState() ;
  }
}

class _DailyActivityInputPageState extends State<DailyActivityInputPage> {
  final TextEditingController _exerciseController = TextEditingController();  
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();

  double _totalCalories = 0.0;
  double _totalWater = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Log Daily Activities",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              //Exercise Input
              _buildInputSection(
                title: "Exercise",
                hint: "e.g., Running, 30 mins",
                controller: _exerciseController,
                onSubmitted: (value) => _logActivity("exercise", value),
              ),    
              
              //Calories Input
              _buildInputSection(
                title: "Calories Consumed",
                hint: "Enter calories",
                controller: _caloriesController,
                onSubmitted: (value) {
                  _totalCalories += double.parse(value);
                  setState(() {});
                },
              ),               

              //Water Intake
              _buildInputSection(
                title: "Water (Glasses)",
                hint: "Enter glasses",
                controller: _waterController,
                onSubmitted: (value) {
                  _totalWater += double.parse(value);
                  setState(() {});
                }
              ),              

              //Sleep Input
              _buildInputSection(
                title: "Sleep (Hours)",
                hint: "Enter hours slept",
                controller: _sleepController,
                onSubmitted: (value) => _logActivity("sleep", value),
              ),   
              
              // Total Section (Calculator function in Action)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: [
                    Text("Today's Totals", 
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTotalChip("Calories", "$_totalCalories kcal"),
                        _buildTotalChip("Water", "$_totalWater glasses"),
                      ],
                    ),
                  ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold,
          ),)
      ],
    );
  }

  void _logActivity(String type, String value) {
    //Saves to database or state management
  }
}