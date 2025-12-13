import '../models/real_time_reading.dart';

class RealTimeParser {
  static dynamic parse(List<int> packet) {
    final kind = RealTimeReadingType.fromValue(packet[1]);
    final errorCode = packet[2];

    if (errorCode != 0) {
      return ReadingError(kind: kind, code: errorCode);
    }

    return Reading(kind: kind, value: packet[3]);
  }
}
