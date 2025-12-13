class HeartRateLogSettings {
  final bool enabled;
  final int interval; // in minutes

  HeartRateLogSettings({
    required this.enabled,
    required this.interval,
  });

  @override
  String toString() => 'HeartRateLogSettings(enabled: $enabled, interval: $interval min)';
}