class FitnessDayData {
  final DateTime date;
  final double calories;
  final double exerciseMinutes;
  final double waterGlasses;
  final double sleepHours;

  FitnessDayData({
    required this.date,
    required this.calories,
    required this.exerciseMinutes,
    required this.waterGlasses,
    required this.sleepHours,
  });

  // Convert a map to FitnessDayData
  factory FitnessDayData.fromMap(Map<String, dynamic> map) {
    return FitnessDayData(
      date: DateTime.parse(map['date']),
      calories: map['calories'] as double,
      exerciseMinutes: map['exercise'] != null ? 
        (map['exercise'] as String).length.toDouble() : 0.0,
      waterGlasses: map['water'] as double,
      sleepHours: map['sleep'] as double,
    );
  }

  // Convert FitnessDayData to a map
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'calories': calories,
      'exercise': exerciseMinutes > 0 ? 'Exercise performed' : null,
      'water': waterGlasses,
      'sleep': sleepHours,
    };
  }

  @override
  String toString() {
    return 'FitnessDayData(date: $date, calories: $calories, '
        'exerciseMinutes: $exerciseMinutes, waterGlasses: $waterGlasses, '
        'sleepHours: $sleepHours)';
  }
}