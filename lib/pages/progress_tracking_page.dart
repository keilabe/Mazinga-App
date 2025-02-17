import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ProgressTrackingPageState();
  }
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {

  // ignore: prefer_final_fields
  String _selectedSort = "date";//Default sorting by date
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _activities = [
    {"date": "2023-10-01", "calories": 500, "duration":30},
    {"date": "2023-10-02", "calories": 700, "duration":45},
    {"date": "2023-10-03", "calories": 300, "duration":20},
  ];

  @override
  Widget build(BuildContext context) {
    _activities.sort((a,b){
      if(_selectedSort == "date") {
        return a["date"].compareTo(b["date"]);
      } else if (_selectedSort == "calories") {
        return b["calories"].compareTo(a["calories"]);
      } else {
        return b["duration"].compareTo(a["duration"]);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tracking Progress"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
          //Sorting Dropdown
          DropdownButton<String>(
            value: _selectedSort,
            items: ["date", "calories", "duration"].map((String value){
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
              LineChartData (
                titlesData: FlTitlesData(show: true),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                  spots: [
                    FlSpot(0, 70),
                    FlSpot(1, 68),
                    FlSpot(2, 66),
                    FlSpot(3, 65),                    
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  ),
                ],
              ),             
            ),
          ),
          //Activity List
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index){
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text("${_activities[index]["date"]}"),
                    subtitle: Text("${_activities[index]["calories"]} kcal . ${_activities[index]["duration"]} mins"),
                    trailing: Icon(Icons.trending_up),
                  ),
                );
              },
          ))
       ] ),
      ),
    );
  }
  
}