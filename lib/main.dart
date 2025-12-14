// import 'package:CareRing/screens/main_screen.dart';
// import 'package:flutter/material.dart';
//
// // // === IMPORT FILE LAIN ==LAIN=
// // import 'pages/Dashboard.dart';
// // import 'pages/HealthMetrics.dart';
// // import 'pages/EmergencyContacts.dart';
// // import 'pages/Medications.dart';
// // import 'pages/Welcome.dart';
//
// void main() {
//   runApp(const CareRingApp());
// }
//
// class CareRingApp extends StatelessWidget {
//   const CareRingApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Colmi R02 Manager',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }
//
// // class CareRingApp extends StatelessWidget {
// //   const CareRingApp({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'CareRing',
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         primaryColor: const Color(0xFF87CEEB),
// //         scaffoldBackgroundColor: const Color(0xFFE8E8E8),
// //       ),
// //       home: const MainScreen(),
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }
// //
// // class MainScreen extends StatefulWidget {
// //   const MainScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }
// //
// // class _MainScreenState extends State<MainScreen> {
// //   bool showWelcome = true;
// //   int currentIndex = 0;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     // === WELCOME SCREEN ===
// //     if (showWelcome) {
// //       return WelcomeScreen(
// //         onGetStarted: () {
// //           setState(() {
// //             showWelcome = false;
// //           });
// //         },
// //       );
// //     }
// //
// //     // === LIST HALAMAN ===
// //     final screens = [
// //       Dashboard(),
// //       HealthMetrics(),
// //       EmergencyContacts(),
// //       Medications(),
// //     ];
// //
// //     return Scaffold(
// //       // === FIX OVERFLOW: SafeArea + SizedBox.expand ===
// //       body: SafeArea(
// //         child: SizedBox.expand(
// //           child: screens[currentIndex],
// //         ),
// //       ),
// //
// //       // === BOTTOM NAV ===
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: currentIndex,
// //         selectedItemColor: Colors.blueAccent,
// //         unselectedItemColor: Colors.grey,
// //         type: BottomNavigationBarType.fixed,
// //         onTap: (index) {
// //           setState(() {
// //             currentIndex = index;
// //           });
// //         },
// //         items: const [
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.dashboard),
// //             label: "Dashboard",
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.favorite),
// //             label: "Health",
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.people),
// //             label: "Contacts",
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.medication),
// //             label: "Meds",
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import pages
import 'pages/Dashboard.dart';
import 'pages/HealthMetrics.dart';
import 'pages/EmergencyContacts.dart';
import 'pages/Medications.dart';
import 'pages/Welcome.dart';

// Import device functionality
import 'colmi_client.dart';
import 'functions/get_heart_rate.dart';
import 'functions/get_steps.dart';
import 'functions/get_info.dart';
import 'functions/get_realtime.dart';
import 'functions/scan_devices.dart';
import 'functions/set_time.dart';
import 'models/real_time_reading.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DeviceState(),
      child: const CareRingApp(),
    ),
  );
}

// Device State Management
class DeviceState extends ChangeNotifier {
  String? _deviceId;
  bool _isConnected = false;
  HealthData? _healthData;
  Timer? _updateTimer;
  bool _isUpdating = false;
  DateTime? _lastUpdate;

  String? get deviceId => _deviceId;
  bool get isConnected => _isConnected;
  HealthData? get healthData => _healthData;
  bool get isUpdating => _isUpdating;
  DateTime? get lastUpdate => _lastUpdate;

  void setDevice(String deviceId) {
    _deviceId = deviceId;
    _isConnected = true;
    notifyListeners();
    _startHealthUpdates();
  }

  void disconnect() {
    _deviceId = null;
    _isConnected = false;
    _updateTimer?.cancel();
    notifyListeners();
  }

  void _startHealthUpdates() {
    _updateTimer?.cancel();
    // Update every 10 seconds for more frequent data
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchHealthData();
    });
    _fetchHealthData(); // Initial fetch
  }

  Future<void> _fetchHealthData() async {
    if (_deviceId == null || _isUpdating) return;

    _isUpdating = true;
    notifyListeners();

    try {
      int heartRate = 72;
      int bloodOxygen = 98;
      int steps = 0;
      int battery = 65;

      // Try to get real-time heart rate
      try {
        final hrReadings = await getRealTimeReading(
          _deviceId!,
          RealTimeReadingType.heartRate,
        ).timeout(const Duration(seconds: 15));

        if (hrReadings != null && hrReadings.isNotEmpty) {
          heartRate = (hrReadings.reduce((a, b) => a + b) / hrReadings.length).round();
        }

        print('Heart rate fetch succeed: $heartRate');
      } catch (e) {
        print('Heart rate fetch failed: $e');
      }

      // Try to get blood oxygen
      try {
        final spo2Readings = await getRealTimeReading(
          _deviceId!,
          RealTimeReadingType.spo2,
        ).timeout(const Duration(seconds: 15));

        if (spo2Readings != null && spo2Readings.isNotEmpty) {
          bloodOxygen = (spo2Readings.reduce((a, b) => a + b) / spo2Readings.length).round();
        }

        print('SpO2 fetch succeed: $bloodOxygen');
      } catch (e) {
        print('SpO2 fetch failed: $e');
      }

      // Try to get steps from today
      try {
        final stepsData = await getSteps(_deviceId!, DateTime.now()).timeout(const Duration(seconds: 15));
        if (stepsData != null && stepsData.isNotEmpty) {
          steps = stepsData.fold<int>(0, (sum, item) => sum + (item['steps'] as int));
        }

        print('Steps fetch succeed: $steps');
      } catch (e) {
        print('Steps fetch failed: $e');
      }

      // Try to get battery info
      try {
        final deviceInfo = await getDeviceInfo(_deviceId!);
        battery = deviceInfo['battery']['level'] as int;

        print('Battery fetch succeed: $battery');
      } catch (e) {
        print('Battery fetch failed: $e');
      }

      _healthData = HealthData(
        heartRate: heartRate,
        steps: steps,
        stepsGoal: 6000,
        sleep: 7.5,
        bloodOxygen: bloodOxygen,
        battery: battery,
        ringConnected: true,
      );

      print('All fetch succeed: $_healthData');
      print('All fetch succeed battery: ${_healthData?.battery}');
      print('All fetch succeed steps: ${_healthData?.steps}');
      print('All fetch succeed heartRate: ${_healthData?.heartRate}');
      print('All fetch succeed bloodOxygen: ${_healthData?.bloodOxygen}');
      print('All fetch succeed ringConnected: ${_healthData?.ringConnected}');

      _lastUpdate = DateTime.now();

    } catch (e) {
      print('Error fetching health data: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Manual refresh function
  Future<void> refreshData() async {
    await _fetchHealthData();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

class CareRingApp extends StatelessWidget {
  const CareRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareRing',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF87CEEB),
        scaffoldBackgroundColor: const Color(0xFFE8E8E8),
      ),
      home: const AppController(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  bool _showWelcome = true;
  bool _showDeviceSetup = false;

  @override
  Widget build(BuildContext context) {
    final deviceState = Provider.of<DeviceState>(context);

    // Show welcome screen
    if (_showWelcome) {
      return WelcomeScreen(
        onGetStarted: () {
          setState(() {
            _showWelcome = false;
            _showDeviceSetup = true;
          });
        },
      );
    }

    // Show device setup if not connected
    if (_showDeviceSetup && !deviceState.isConnected) {
      return DeviceSetupScreen(
        onDeviceConnected: (deviceId) {
          deviceState.setDevice(deviceId);
          setState(() {
            _showDeviceSetup = false;
          });
        },
        onSkip: () {
          setState(() {
            _showDeviceSetup = false;
          });
        },
      );
    }

    // Show main app
    return const MainNavigationScreen();
  }
}

class DeviceSetupScreen extends StatefulWidget {
  final Function(String) onDeviceConnected;
  final VoidCallback onSkip;

  const DeviceSetupScreen({
    super.key,
    required this.onDeviceConnected,
    required this.onSkip,
  });

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to device...'),
          ],
        ),
      ),
    );

    try {
      // Simple connection test - just try to create and connect client
      final client = ColmiClient(deviceId);
      await client.connect();
      // TODO
      // await client.disconnect();

      if (mounted) {
        Navigator.pop(context);
        widget.onDeviceConnected(deviceId);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Ring'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Scan for your CareRing device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
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
                    backgroundColor: const Color(0xFF87CEEB),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip for now'),
                ),
              ],
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
                  leading: const Icon(Icons.bluetooth, color: Color(0xFF87CEEB)),
                  title: Text(device['name'] ?? 'Unknown'),
                  subtitle: Text(device['id'] ?? ''),
                  trailing: Text(device['rssi'] ?? ''),
                  onTap: () {
                    final deviceId = device['id'];
                    if (deviceId != null) {
                      _connectToDevice(deviceId);
                    }
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deviceState = Provider.of<DeviceState>(context);

    final screens = [
      const Dashboard(),
      const HealthMetrics(),
      const EmergencyContacts(),
      const Medications(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              child: Text(
                'CareRing',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (deviceState.isUpdating) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF87CEEB),
        actions: [
          if (deviceState.isConnected)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh data',
              onPressed: () async {
                await deviceState.refreshData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data refreshed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          if (deviceState.isConnected)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeviceSettingsScreen(),
                  ),
                );
              },
            ),
          if (!deviceState.isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_searching),
              tooltip: 'Connect device',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceSetupScreen(
                      onDeviceConnected: (id) {
                        deviceState.setDevice(id);
                        Navigator.pop(context);
                      },
                      onSkip: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF87CEEB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Health",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Meds",
          ),
        ],
      ),
    );
  }
}

class DeviceSettingsScreen extends StatelessWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceState = Provider.of<DeviceState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Settings'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: const Text('Connected Device'),
            subtitle: Text(deviceState.deviceId ?? 'None'),
          ),
          if (deviceState.lastUpdate != null)
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Last Update'),
              subtitle: Text(
                '${deviceState.lastUpdate!.hour}:${deviceState.lastUpdate!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Sync Time'),
            subtitle: const Text('Set ring time to phone time'),
            onTap: () async {
              if (deviceState.deviceId != null) {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  await setRingTime(deviceState.deviceId!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Time synced successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Health Data'),
            subtitle: const Text('Force refresh all data now'),
            onTap: () async {
              await deviceState.refreshData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data refreshed')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bluetooth_disabled),
            title: const Text('Disconnect'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              deviceState.disconnect();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Device disconnected')),
              );
            },
          ),
        ],
      ),
    );
  }
}
