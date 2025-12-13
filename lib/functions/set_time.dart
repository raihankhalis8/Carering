import '../colmi_client.dart';

Future<void> setRingTime(String deviceId, {DateTime? time}) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    await client.setTime(time ?? DateTime.now().toUtc());
    print('Time set successfully');
  } finally {
    await client.disconnect();
  }
}
