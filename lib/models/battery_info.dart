class BatteryInfo {
  final int batteryLevel;
  final bool charging;

  BatteryInfo({
    required this.batteryLevel,
    required this.charging,
  });

  @override
  String toString() => 'BatteryInfo(level: $batteryLevel%, charging: $charging)';
}