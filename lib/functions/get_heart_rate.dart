import '../colmi_client.dart';

Future<List<Map<String, dynamic>>?> getHeartRateLog(
    String deviceId,
    DateTime date,
    ) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    final log = await client.getHeartRateLog(date);

    if (log == null) {
      print('No heart rate data for this date');
      return null;
    }

    final readings = log.heartRatesWithTimes();
    return readings
        .where((r) => r.reading != 0)
        .map((r) => {
      'time': r.timestamp.toIso8601String(),
      'reading': r.reading,
      'time_formatted':
      '${r.timestamp.hour.toString().padLeft(2, '0')}:'
          '${r.timestamp.minute.toString().padLeft(2, '0')}',
    })
        .toList();
  } finally {
    await client.disconnect();
  }
}