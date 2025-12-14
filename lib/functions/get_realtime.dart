import '../colmi_client.dart';
import '../models/real_time_reading.dart';

Future<List<int>?> getRealTimeReading(
    String deviceId,
    RealTimeReadingType readingType,
    ) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    print('Starting reading, please wait...');

    final readings = await client.getRealTimeReading(readingType);
    if (readings == null || readings.isEmpty) {
      print('Error: No reading detected. Is the ring being worn?');
      return null;
    }

    return readings;
  } catch (e) {
    print('Error: $e');
    rethrow;
  // } finally {
  //   await client.disconnect();
  }
}

Future<double?> getAverageRealTimeReading(
    String deviceId,
    RealTimeReadingType readingType,
    ) async {
  final readings = await getRealTimeReading(deviceId, readingType);
  if (readings == null || readings.isEmpty) return null;

  return readings.reduce((a, b) => a + b) / readings.length;
}
