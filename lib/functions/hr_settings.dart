import '../colmi_client.dart';
import '../models/hr_settings.dart';

Future<HeartRateLogSettings> getHeartRateSettings(String deviceId) async {
  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    return await client.getHeartRateLogSettings();
  } catch (e) {
    print('Error getting heart rate settings: $e');
    rethrow;
  // } finally {
  //   await client.disconnect();
  }
}

Future<HeartRateLogSettings> setHeartRateSettings(
    String deviceId, {
      required bool enabled,
      required int interval,
    }) async {
  if (interval <= 0 || interval > 255) {
    throw ArgumentError('Interval must be between 1 and 255 minutes');
  }

  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    print('Changing heart rate log settings...');

    await client.setHeartRateLogSettings(enabled, interval);
    final newSettings = await client.getHeartRateLogSettings();

    print('Settings updated: $newSettings');
    return newSettings;
  } catch (e) {
    print('Error setting heart rate settings: $e');
    rethrow;
  // } finally {
  //   await client.disconnect();
  }
}