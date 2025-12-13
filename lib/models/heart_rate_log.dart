class HeartRateLog {
  final List<int> heartRates;
  final DateTime timestamp;
  final int size;
  final int index;
  final int range;

  HeartRateLog({
    required this.heartRates,
    required this.timestamp,
    required this.size,
    required this.index,
    required this.range,
  });

  List<HeartRateReading> heartRatesWithTimes() {
    final List<HeartRateReading> result = [];
    DateTime current = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      0, 0, 0,
    ).toUtc();

    for (int hr in heartRates) {
      result.add(HeartRateReading(reading: hr, timestamp: current));
      current = current.add(const Duration(minutes: 5));
    }

    return result;
  }
}

class HeartRateReading {
  final int reading;
  final DateTime timestamp;

  HeartRateReading({
    required this.reading,
    required this.timestamp,
  });
}