import '../colmi_client.dart';

Future<List<Map<String, dynamic>>?> getSteps(
    String deviceId,
    DateTime date,
    ) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    final sportDetails = await client.getSteps(date);

    if (sportDetails == null) {
      print('No step data for this date');
      return null;
    }

    return sportDetails.map((detail) => detail.toJson()).toList();
  } finally {
    await client.disconnect();
  }
}

Future<String?> getStepsAsCsv(String deviceId, DateTime date) async {
  final data = await getSteps(deviceId, date);
  if (data == null) return null;

  final csv = StringBuffer();
  csv.writeln('year,month,day,timeIndex,calories,steps,distance,timestamp');

  for (var row in data) {
    csv.writeln('${row['year']},${row['month']},${row['day']},'
        '${row['timeIndex']},${row['calories']},${row['steps']},'
        '${row['distance']},${row['timestamp']}');
  }

  return csv.toString();
}