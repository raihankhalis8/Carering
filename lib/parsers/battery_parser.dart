import '../models/battery_info.dart';

class BatteryParser {
  static BatteryInfo parse(List<int> packet) {
    return BatteryInfo(
      batteryLevel: packet[1],
      charging: packet[2] != 0,
    );
  }
}