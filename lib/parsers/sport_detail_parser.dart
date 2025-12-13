import '../models/sport_detail.dart';
import '../utils/packet.dart';

class SportDetailParser {
  bool newCalorieProtocol = false;
  int index = 0;
  List<SportDetail> details = [];

  void reset() {
    newCalorieProtocol = false;
    index = 0;
    details = [];
  }

  List<SportDetail>? parse(List<int> packet) {
    if (index == 0 && packet[1] == 255) {
      reset();
      return null; // NoData
    }

    if (index == 0 && packet[1] == 240) {
      if (packet[3] == 1) {
        newCalorieProtocol = true;
      }
      index++;
      return null;
    }

    final year = PacketUtils.bcdToDecimal(packet[1]) + 2000;
    final month = PacketUtils.bcdToDecimal(packet[2]);
    final day = PacketUtils.bcdToDecimal(packet[3]);
    final timeIndex = packet[4];

    int calories = packet[7] | (packet[8] << 8);
    if (newCalorieProtocol) {
      calories *= 10;
    }

    final steps = packet[9] | (packet[10] << 8);
    final distance = packet[11] | (packet[12] << 8);

    final detail = SportDetail(
      year: year,
      month: month,
      day: day,
      timeIndex: timeIndex,
      calories: calories,
      steps: steps,
      distance: distance,
    );

    details.add(detail);

    if (packet[5] == packet[6] - 1) {
      final result = List<SportDetail>.from(details);
      reset();
      return result;
    }

    index++;
    return null;
  }
}