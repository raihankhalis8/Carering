import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'models/battery_info.dart';
import 'models/heart_rate_log.dart';
import 'models/sport_detail.dart';
import 'models/real_time_reading.dart';
import 'models/hr_settings.dart';
import 'parsers/battery_parser.dart';
import 'parsers/heart_rate_parser.dart';
import 'parsers/sport_detail_parser.dart';
import 'parsers/real_time_parser.dart';
import 'parsers/hr_settings_parser.dart';
import 'utils/packet.dart';
import 'utils/commands.dart';
import 'utils/uuids.dart';

class ColmiClient {
  final String deviceId;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  BluetoothCharacteristic? _txChar;

  final Map<int, StreamController<dynamic>> _controllers = {};
  final Map<int, Function(List<int>)> _parsers = {};

  // State parsers
  final HeartRateLogParser _hrParser = HeartRateLogParser();
  final SportDetailParser _sportParser = SportDetailParser();

  ColmiClient(this.deviceId) {
    _initializeParsers();
  }

  void _initializeParsers() {
    _parsers[Commands.cmdBattery] = (packet) {
      final result = BatteryParser.parse(packet);
      _controllers[Commands.cmdBattery]?.add(result);
    };

    _parsers[Commands.cmdReadHeartRate] = (packet) {
      final result = _hrParser.parse(packet);
      if (result != null) {
        _controllers[Commands.cmdReadHeartRate]?.add(result);
      }
    };

    _parsers[Commands.cmdGetStepSomeday] = (packet) {
      final result = _sportParser.parse(packet);
      if (result != null) {
        _controllers[Commands.cmdGetStepSomeday]?.add(result);
      }
    };

    _parsers[Commands.cmdStartRealTime] = (packet) {
      final result = RealTimeParser.parse(packet);
      _controllers[Commands.cmdStartRealTime]?.add(result);
    };

    _parsers[Commands.cmdHeartRateLogSettings] = (packet) {
      final result = HeartRateSettingsParser.parse(packet);
      _controllers[Commands.cmdHeartRateLogSettings]?.add(result);
    };
  }

  Future<void> connect() async {
    _device = BluetoothDevice.fromId(deviceId);
    await _device!.connect(timeout: const Duration(seconds: 15));

    final services = await _device!.discoverServices();
    final uartService = services.firstWhere(
          (s) => s.uuid.toString().toUpperCase() == ColmiUuids.uartServiceUuid.toUpperCase(),
    );

    _rxChar = uartService.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == ColmiUuids.uartRxCharUuid.toUpperCase(),
    );

    _txChar = uartService.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == ColmiUuids.uartTxCharUuid.toUpperCase(),
    );

    await _txChar!.setNotifyValue(true);
    _txChar!.lastValueStream.listen(_handleNotification);

    for (var cmd in _parsers.keys) {
      _controllers[cmd] = StreamController<dynamic>.broadcast();
    }
  }

  //TODO usage nya delete dlu, soalnya race condition jadinya disconnected
  Future<void> disconnect() async {
    for (var controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    await _device?.disconnect();
  }

  void _handleNotification(List<int> data) {
    if (data.length != 16) return;
    final packetType = data[0];
    if (packetType >= 127) return;

    if (_parsers.containsKey(packetType)) {
      _parsers[packetType]!(data);
    }
  }

  Future<void> _sendPacket(List<int> packet) async {
    await _rxChar!.write(packet, withoutResponse: true);
  }

  Future<BatteryInfo> getBattery() async {
    final packet = PacketUtils.makePacket(Commands.cmdBattery);
    await _sendPacket(packet);
    final result = await _controllers[Commands.cmdBattery]!.stream.first
        .timeout(const Duration(seconds: 5));
    return result as BatteryInfo;
  }

  Future<Map<String, String>> getDeviceInfo() async {
    print("Start Device Info");
    final services = await _device!.discoverServices(timeout: 60);
    final deviceInfoService = services.firstWhere(
          (s) => s.uuid.toString().toUpperCase() == ColmiUuids.deviceInfoUuid.toUpperCase(),
    );

    print("deviceInfoService");
    print(deviceInfoService);

    final hwChar = deviceInfoService.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == ColmiUuids.deviceHwUuid.toUpperCase(),
    );
    final hwVersion = await hwChar.read();

    final fwChar = deviceInfoService.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == ColmiUuids.deviceFwUuid.toUpperCase(),
    );
    final fwVersion = await fwChar.read();

    return {
      'hw_version': String.fromCharCodes(hwVersion),
      'fw_version': String.fromCharCodes(fwVersion),
    };
  }

  Future<void> setTime(DateTime time) async {
    final utcTime = time.toUtc();
    final year = utcTime.year % 2000;

    final data = [
      PacketUtils.byteToBcd(year),
      PacketUtils.byteToBcd(utcTime.month),
      PacketUtils.byteToBcd(utcTime.day),
      PacketUtils.byteToBcd(utcTime.hour),
      PacketUtils.byteToBcd(utcTime.minute),
      PacketUtils.byteToBcd(utcTime.second),
      1,
    ];

    final packet = PacketUtils.makePacket(Commands.cmdSetTime, data);
    await _sendPacket(packet);
  }

  Future<HeartRateLog?> getHeartRateLog(DateTime date) async {
    final midnight = DateTime.utc(date.year, date.month, date.day);
    final timestamp = midnight.millisecondsSinceEpoch ~/ 1000;

    final data = [
      timestamp & 0xFF,
      (timestamp >> 8) & 0xFF,
      (timestamp >> 16) & 0xFF,
      (timestamp >> 24) & 0xFF,
    ];

    final packet = PacketUtils.makePacket(Commands.cmdReadHeartRate, data);
    await _sendPacket(packet);

    try {
      final result = await _controllers[Commands.cmdReadHeartRate]!.stream.first
          .timeout(const Duration(seconds: 5));
      return result as HeartRateLog?;
    } catch (e) {
      return null;
    }
  }

  Future<List<SportDetail>?> getSteps(DateTime date) async {
    final today = DateTime.now().toUtc();
    final targetDate = date.toUtc();
    final daysDiff = today.difference(targetDate).inDays;

    final data = [daysDiff, 0x0f, 0x00, 0x5f, 0x01];
    final packet = PacketUtils.makePacket(Commands.cmdGetStepSomeday, data);
    await _sendPacket(packet);

    try {
      final result = await _controllers[Commands.cmdGetStepSomeday]!.stream.first
          .timeout(const Duration(seconds: 5));
      return result as List<SportDetail>?;
    } catch (e) {
      return null;
    }
  }

  Future<HeartRateLogSettings> getHeartRateLogSettings() async {
    final packet = PacketUtils.makePacket(Commands.cmdHeartRateLogSettings, [0x01]);
    await _sendPacket(packet);
    final result = await _controllers[Commands.cmdHeartRateLogSettings]!.stream.first
        .timeout(const Duration(seconds: 5));
    return result as HeartRateLogSettings;
  }

  Future<void> setHeartRateLogSettings(bool enabled, int interval) async {
    assert(interval > 0 && interval < 256);
    final enabledByte = enabled ? 1 : 2;
    final data = [0x02, enabledByte, interval];
    final packet = PacketUtils.makePacket(Commands.cmdHeartRateLogSettings, data);
    await _sendPacket(packet);
    await _controllers[Commands.cmdHeartRateLogSettings]!.stream.first
        .timeout(const Duration(seconds: 5));
  }

  Future<List<int>?> getRealTimeReading(RealTimeReadingType readingType) async {
    final validReadings = <int>[];
    int tries = 0;
    bool error = false;

    final startPacket = PacketUtils.makePacket(
      Commands.cmdStartRealTime,
      [readingType.value, 1],
    );
    await _sendPacket(startPacket);

    while (validReadings.length < 6 && tries < 20) {
      try {
        final result = await _controllers[Commands.cmdStartRealTime]!.stream.first
            .timeout(const Duration(seconds: 2));

        if (result is ReadingError) {
          error = true;
          break;
        }

        if (result is Reading && result.value != 0) {
          validReadings.add(result.value);
        }
      } catch (e) {
        tries++;
      }
    }

    final stopPacket = PacketUtils.makePacket(
      Commands.cmdStopRealTime,
      [readingType.value, 0, 0],
    );
    await _sendPacket(stopPacket);

    return error ? null : validReadings;
  }

  Future<void> reboot() async {
    final packet = PacketUtils.makePacket(Commands.cmdReboot, [0x01]);
    await _sendPacket(packet);
  }

  Future<void> blinkTwice() async {
    final packet = PacketUtils.makePacket(Commands.cmdBlinkTwice);
    await _sendPacket(packet);
  }

  Future<List<List<int>>> sendRawCommand(
      int command,
      List<int>? subdata,
      int expectedReplies,
      ) async {
    final packet = PacketUtils.makePacket(command, subdata);
    await _sendPacket(packet);

    final results = <List<int>>[];
    if (!_controllers.containsKey(command)) {
      _controllers[command] = StreamController<dynamic>.broadcast();
    }

    for (int i = 0; i < expectedReplies; i++) {
      try {
        final result = await _controllers[command]!.stream.first
            .timeout(const Duration(seconds: 2));
        results.add(result as List<int>);
      } catch (e) {
        // Timeout
      }
    }
    return results;
  }
}