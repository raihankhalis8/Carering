enum RealTimeReadingType {
  heartRate(1),
  bloodPressure(2),
  spo2(3),
  fatigue(4),
  healthCheck(5),
  ecg(7),
  pressure(8),
  bloodSugar(9),
  hrv(10);

  final int value;
  const RealTimeReadingType(this.value);

  static RealTimeReadingType fromValue(int value) {
    return RealTimeReadingType.values.firstWhere((e) => e.value == value);
  }
}

class Reading {
  final RealTimeReadingType kind;
  final int value;

  Reading({required this.kind, required this.value});
}

class ReadingError {
  final RealTimeReadingType kind;
  final int code;

  ReadingError({required this.kind, required this.code});
}