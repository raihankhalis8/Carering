import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ColmiScanner {
  static const List<String> deviceNamePrefixes = [
    "R01", "R02", "R03", "R04", "R05", "R06", "R07", "R09", "R10",
    "COLMI", "VK-5098", "MERLIN", "Hello Ring", "RING1", "boAtring",
    "TR-R02", "SE", "EVOLVEO", "GL-SR2", "Blaupunkt", "KSIX RING",
  ];

  static Future<List<ScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 15),
    bool filterByName = true,
  }) async {
    final devices = <ScanResult>[];
    await FlutterBluePlus.startScan(timeout: timeout);

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (!filterByName || _isColmiDevice(result.device.platformName)) {
          if (!devices.any((d) => d.device.remoteId == result.device.remoteId)) {
            devices.add(result);
          }
        }
      }
    });

    await Future.delayed(timeout);
    await subscription.cancel();
    await FlutterBluePlus.stopScan();
    return devices;
  }

  static bool _isColmiDevice(String name) {
    if (name.isEmpty) return false;
    return deviceNamePrefixes.any((prefix) => name.startsWith(prefix));
  }
}