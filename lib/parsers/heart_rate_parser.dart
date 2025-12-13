import '../models/heart_rate_log.dart';

class HeartRateLogParser {
  List<int> _rawHeartRates = [];
  DateTime? timestamp;
  int size = 0;
  int index = 0;
  int range = 5;

  void reset() {
    _rawHeartRates = [];
    timestamp = null;
    size = 0;
    index = 0;
    range = 5;
  }

  bool get isToday {
    if (timestamp == null) return false;
    final now = DateTime.now().toUtc();
    return timestamp!.year == now.year &&
        timestamp!.month == now.month &&
        timestamp!.day == now.day;
  }

  HeartRateLog? parse(List<int> packet) {
    final subType = packet[1];

    if (subType == 255) {
      reset();
      return null; // NoData case
    }

    if (isToday && subType == 23) {
      final result = HeartRateLog(
        heartRates: _normalizeHeartRates(),
        timestamp: timestamp!,
        size: size,
        range: range,
        index: index,
      );
      reset();
      return result;
    }

    if (subType == 0) {
      size = packet[2];
      range = packet[3];
      _rawHeartRates = List.filled(size * 13, -1);
      return null;
    }

    if (subType == 1) {
      final ts = _bytesToInt(packet.sublist(2, 6));
      timestamp = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);

      for (int i = 0; i < 9; i++) {
        _rawHeartRates[i] = packet[6 + i];
      }
      index += 9;
      return null;
    }

    // subType > 1
    for (int i = 0; i < 13; i++) {
      _rawHeartRates[index + i] = packet[2 + i];
    }
    index += 13;

    if (subType == size - 1) {
      final result = HeartRateLog(
        heartRates: _normalizeHeartRates(),
        timestamp: timestamp!,
        size: size,
        range: range,
        index: index,
      );
      reset();
      return result;
    }

    return null;
  }

  List<int> _normalizeHeartRates() {
    List<int> hr = List.from(_rawHeartRates);

    if (hr.length > 288) {
      hr = hr.sublist(0, 288);
    } else if (hr.length < 288) {
      hr.addAll(List.filled(288 - hr.length, 0));
    }

    if (isToday) {
      final now = DateTime.now().toUtc();
      final midnight = DateTime(now.year, now.month, now.day).toUtc();
      final minutesSoFar = now.difference(midnight).inMinutes;
      final m = (minutesSoFar ~/ 5) + 1;
      if (m < hr.length) {
        hr.fillRange(m, hr.length, 0);
      }
    }

    return hr;
  }

  int _bytesToInt(List<int> bytes) {
    int result = 0;
    for (int i = 0; i < bytes.length; i++) {
      result |= (bytes[i] & 0xFF) << (i * 8);
    }
    return result;
  }
}