import 'package:flutter/material.dart';
import 'device_scanner_screen.dart';
import 'device_info_screen.dart';
import 'heart_rate_screen.dart';
import 'realtime_reading_screen.dart';
import '../functions/set_time.dart';
import '../functions/reboot.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _deviceId;

  Future<void> _scanForDevice() async {
    final deviceId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const DeviceScannerScreen()),
    );

    if (deviceId != null) {
      setState(() {
        _deviceId = deviceId;
      });
    }
  }

  Future<void> _setTime() async {
    if (_deviceId == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await setRingTime(_deviceId!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time set successfully')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _reboot() async {
    if (_deviceId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reboot Ring'),
        content: const Text('Are you sure you want to reboot the ring?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reboot'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await rebootRing(_deviceId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ring rebooted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colmi R02 Manager'),
        actions: [
          if (_deviceId != null)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: () {
                setState(() {
                  _deviceId = null;
                });
              },
            ),
        ],
      ),
      body: _deviceId == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_searching, size: 64),
            const SizedBox(height: 24),
            const Text('No device connected'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _scanForDevice,
              icon: const Icon(Icons.search),
              label: const Text('Scan for Devices'),
            ),
          ],
        ),
      )
          : ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: const Text('Connected Device'),
            subtitle: Text(_deviceId!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Device Info & Battery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceInfoScreen(deviceId: _deviceId!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Heart Rate Log'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HeartRateScreen(deviceId: _deviceId!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text('Real-time Reading'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RealtimeReadingScreen(deviceId: _deviceId!),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Set Time'),
            onTap: _setTime,
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reboot Ring'),
            onTap: _reboot,
          ),
        ],
      ),
    );
  }
}