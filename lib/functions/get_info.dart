import '../colmi_client.dart';

Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    final deviceInfo = await client.getDeviceInfo();
    final batteryInfo = await client.getBattery();

    return {
      'device_info': deviceInfo,
      'battery': {
        'level': batteryInfo.batteryLevel,
        'charging': batteryInfo.charging,
      },
    };
  } finally {
    await client.disconnect();
  }
}