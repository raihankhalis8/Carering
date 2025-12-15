import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/app_state.dart';
import 'pages/Dashboard.dart';
import 'pages/HealthMetrics.dart';
import 'pages/EmergencyContacts.dart';
import 'pages/Medications.dart';
import 'pages/Welcome.dart';
import 'functions/scan_devices.dart';
import 'colmi_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CareRingApp(),
    ),
  );
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final welcomeShown = StorageService.getWelcomeShown();

    if (!welcomeShown) {
      return WelcomeScreen(
        onGetStarted: () {
          StorageService.setWelcomeShown(true);
          setState(() {});
        },
      );
    }

    return const MainNavigationScreen();
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
    final appState = Provider.of<AppState>(context);

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
            if (appState.isUpdating) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF87CEEB),
        actions: [
          if (appState.isConnected)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh data',
              onPressed: () async {
                await appState.refreshData();
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
          if (!appState.isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_searching),
              tooltip: 'Connect device',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceSetupScreen(
                      onDeviceConnected: (id) {
                        appState.setDevice(id);
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
      final client = ColmiClient(deviceId);
      await client.connect();

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

class DeviceSettingsScreen extends StatelessWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: ListView(
        children: [
          if (appState.isConnected) ...[
            ListTile(
              leading: const Icon(Icons.bluetooth_connected),
              title: const Text('Connected Device'),
              subtitle: Text(appState.deviceId ?? 'None'),
            ),
            if (appState.lastUpdate != null)
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Last Update'),
                subtitle: Text(
                  '${appState.lastUpdate!.hour}:${appState.lastUpdate!.minute.toString().padLeft(2, '0')}',
                ),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Health Data'),
              subtitle: const Text('Force refresh all data now'),
              onTap: () async {
                await appState.refreshData();
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
                appState.disconnect();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device disconnected')),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.bluetooth_searching),
              title: const Text('Connect Device'),
              subtitle: const Text('Scan for nearby devices'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceSetupScreen(
                      onDeviceConnected: (id) {
                        appState.setDevice(id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onSkip: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear All Data'),
            subtitle: const Text('Reset app to initial state'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data?'),
                  content: const Text(
                    'This will delete all medications, contacts, and SOS history. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await StorageService.clearAll();
                await appState.initialize();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}