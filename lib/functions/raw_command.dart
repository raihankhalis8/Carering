import '../colmi_client.dart';

Future<List<List<int>>> sendRawCommand(
    String deviceId, {
      required int command,
      List<int>? subdata,
      int replies = 0,
    }) async {
  if (command < 0 || command > 255) {
    throw ArgumentError('Command must be between 0 and 255');
  }

  final client = ColmiClient(deviceId);

  try {
    await client.connect();
    return await client.sendRawCommand(command, subdata, replies);
  } finally {
    await client.disconnect();
  }
}
