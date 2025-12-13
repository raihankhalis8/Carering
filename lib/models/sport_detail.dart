class SportDetail {
  final int year;
  final int month;
  final int day;
  final int timeIndex;
  final int calories;
  final int steps;
  final int distance; // in meters

  SportDetail({
    required this.year,
    required this.month,
    required this.day,
    required this.timeIndex,
    required this.calories,
    required this.steps,
    required this.distance,
  });

  DateTime get timestamp {
    return DateTime.utc(
      year,
      month,
      day,
      timeIndex ~/ 4,
      (timeIndex % 4) * 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'timeIndex': timeIndex,
      'calories': calories,
      'steps': steps,
      'distance': distance,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}