import 'package:flutter/material.dart';
import '../functions/scan_devices.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  State<DeviceScannerScreen> createState() => _DeviceScannerScreenState();
}

class _DeviceScannerScreenState extends State<DeviceScannerScreen> {
  List<Map<String, String>> _devices = [];
  bool _isScanning = false;

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    try {
      final devices = await scanDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan error: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Devices'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: _isScanning
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.search),
              label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          Expanded(
            child: _devices.isEmpty
                ? Center(
              child: Text(
                _isScanning
                    ? 'Scanning for devices...'
                    : 'No devices found. Tap button to scan.',
              ),
            )
                : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device['name'] ?? 'Unknown'),
                  subtitle: Text(device['id'] ?? ''),
                  trailing: Text(device['rssi'] ?? ''),
                  onTap: () {
                    Navigator.pop(context, device['id']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
