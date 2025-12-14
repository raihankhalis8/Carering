
import '../colmi_client.dart';

Future<void> rebootRing(String deviceId) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    await client.reboot();
    print('Ring rebooted');
  } catch (e) {
    print('Error: $e');
    rethrow;
  // } finally {
  //   await client.disconnect();
  }
}
