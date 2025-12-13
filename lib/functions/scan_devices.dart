import '../colmi_scanner.dart';

Future<List<Map<String, String>>> scanDevices({bool showAll = false}) async {
  final results = await ColmiScanner.scanForDevices(
    timeout: const Duration(seconds: 15),
    filterByName: !showAll,
  );

  return results.map((result) {
    return {
      'name': result.device.platformName,
      'id': result.device.remoteId.toString(),
      'rssi': '${result.rssi} dBm',
    };
  }).toList();
}