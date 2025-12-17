import '../colmi_client.dart';

Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    // final deviceInfo = await client.getDeviceInfo();
    // print("Device Info Success");
    // print(deviceInfo);
    final batteryInfo = await client.getBattery();
    print("Battery Info Success");
    print(batteryInfo);

    return {
      // 'device_info': deviceInfo,
      'battery': {
        'level': batteryInfo.batteryLevel,
        'charging': batteryInfo.charging,
      },
    };
  } catch (e) {
    print('Error: $e');
    rethrow;
  // } finally {
  //   await client.disconnect();
  }
}