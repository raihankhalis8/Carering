import '../models/hr_settings.dart';

class HeartRateSettingsParser {
  static HeartRateLogSettings parse(List<int> packet) {
    final rawEnabled = packet[2];
    final enabled = rawEnabled == 1;
    final interval = packet[3];

    return HeartRateLogSettings(
      enabled: enabled,
      interval: interval,
    );
  }
}