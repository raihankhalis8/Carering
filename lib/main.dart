import 'package:flutter/material.dart';

void main() {
  runApp(const CareRingApp());
}

class CareRingApp extends StatelessWidget {
  const CareRingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareRing',
      theme: ThemeData(
        primaryColor: const Color(0xFF87CEEB),
        scaffoldBackgroundColor: const Color(0xFFE8E8E8),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showWelcome = true;
  int activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (showWelcome) {
      return WelcomeScreen(
        onGetStarted: () {
          setState(() {
            showWelcome = false;
          });
        },
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8E8E8), Color(0xFFF5F5F5)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: const [
                      Text(
                        'CareRing',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF87CEEB),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your health companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.favorite, 'Health'),
                _buildNavItem(2, Icons.people, 'Contacts'),
                _buildNavItem(3, Icons.medication, 'Meds'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            activeTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF87CEEB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isActive ? Colors.grey.shade800 : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.grey.shade800 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (activeTabIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const HealthMetricsScreen();
      case 2:
        return const EmergencyContactsScreen();
      case 3:
        return const MedicationsScreen();
      default:
        return const DashboardScreen();
    }
  }
}

// Welcome Screen
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({Key? key, required this.onGetStarted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF87CEEB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CareRing',
                        style: TextStyle(
                          fontSize: 32,
                          color: Color(0xFF2D3748),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Subtitle
                      const Text(
                        'Your personal health companion for monitoring vital signs and staying safe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF718096),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Feature List
                      _buildFeatureCard(
                        icon: Icons.favorite,
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFFF0F8FF),
                        circleColor: const Color(0xFF87CEEB),
                        title: 'Health Monitoring',
                        description: 'Track heart rate, blood oxygen, steps, and sleep',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.shield,
                        iconColor: const Color(0xFF2D3748),
                        backgroundColor: const Color(0xFFFFF9E6),
                        circleColor: const Color(0xFFFFE66D),
                        title: 'Emergency SOS',
                        description: 'Automatic alerts when health values are concerning',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.medication,
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFFFFE8E8),
                        circleColor: const Color(0xFFFF6B9D),
                        title: 'Medication Reminders',
                        description: 'Never miss your medications with timely alerts',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.notifications,
                        iconColor: Colors.white,
                        backgroundColor: const Color(0xFFE8F5E9),
                        circleColor: const Color(0xFF98D8C8),
                        title: 'Smart Alerts',
                        description: 'Get notified about important health changes',
                      ),
                      const SizedBox(height: 40),

                      // Get Started Button
                      InkWell(
                        onTap: onGetStarted,
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF87CEEB).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer text
                      const Text(
                        'Designed for easy use with large buttons and clear text',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color circleColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> healthData = {
    'heartRate': 72,
    'steps': 4234,
    'stepsGoal': 6000,
    'sleep': 7.5,
    'bloodOxygen': 98,
    'battery': 65,
    'ringConnected': true,
  };

  bool sosActive = false;
  String sosTrigger = 'manual';
  String sosReason = '';

  @override
  void initState() {
    super.initState();
    _startHealthDataUpdates();
  }

  void _startHealthDataUpdates() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          // Simulate real-time health data updates
          healthData['heartRate'] = healthData['heartRate'] + (DateTime.now().millisecond % 7 - 3);
          healthData['bloodOxygen'] = (healthData['bloodOxygen'] + (DateTime.now().millisecond % 3 - 1))
              .clamp(88, 100);
          healthData['steps'] = healthData['steps'] + (DateTime.now().millisecond % 50);
        });
        _startHealthDataUpdates();
      }
    });
  }

  void _handleManualSOS() {
    setState(() {
      sosTrigger = 'manual';
      sosReason = 'Manual emergency activation';
      sosActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.phone, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Emergency SOS Activated!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Contacting emergency services...',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleSOSCancel() {
    setState(() {
      sosActive = false;
      sosReason = '';
    });
  }

  HealthStatus _getHealthStatus(String metric, dynamic value) {
    switch (metric) {
      case 'heartRate':
        if (value < 50 || value > 110) {
          return HealthStatus('critical', 'text-[#d97066]', 'bg-[#FAA09A]/40');
        } else if (value < 60 || value > 100) {
          return HealthStatus('warning', 'text-[#d4b84a]', 'bg-[#F4E87C]/40');
        }
        return HealthStatus('normal', 'text-[#6fbb8a]', 'bg-[#B4F8C8]/40');

      case 'bloodOxygen':
        if (value < 90) {
          return HealthStatus('critical', 'text-[#d97066]', 'bg-[#FAA09A]/40');
        } else if (value < 95) {
          return HealthStatus('warning', 'text-[#d4b84a]', 'bg-[#F4E87C]/40');
        }
        return HealthStatus('normal', 'text-[#6fbb8a]', 'bg-[#B4F8C8]/40');

      case 'sleep':
        if (value < 5) {
          return HealthStatus('critical', 'text-[#d97066]', 'bg-[#FAA09A]/40');
        } else if (value < 6) {
          return HealthStatus('warning', 'text-[#d4b84a]', 'bg-[#F4E87C]/40');
        }
        return HealthStatus('normal', 'text-[#6fbb8a]', 'bg-[#B4F8C8]/40');

      default:
        return HealthStatus('normal', 'text-[#6fbb8a]', 'bg-[#B4F8C8]/40');
    }
  }

  @override
  Widget build(BuildContext context) {
    final heartRateStatus = _getHealthStatus('heartRate', healthData['heartRate']);
    final bloodOxygenStatus = _getHealthStatus('bloodOxygen', healthData['bloodOxygen']);
    final sleepStatus = _getHealthStatus('sleep', healthData['sleep']);

    return SingleChildScrollView(
      child: Column(
        children: [
          // SOS Status Alert
          if (sosActive)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAA09A).withOpacity(0.2),
                border: Border.all(color: const Color(0xFFFAA09A), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Color(0xFFd97066), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🚨 SOS ACTIVE - Emergency contacts notified!',
                      style: TextStyle(color: Color(0xFFd97066), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Ring Status Card
          _buildRingStatusCard(),
          const SizedBox(height: 16),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: '${healthData['heartRate']} BPM',
                  status: heartRateStatus,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: healthData['steps'].toString(),
                  status: HealthStatus('normal', 'text-[#6fbb8a]', 'bg-[#B4F8C8]/40'),
                  showProgress: true,
                  progress: (healthData['steps'] / healthData['stepsGoal']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.nightlight_round,
                  label: 'Sleep',
                  value: '${healthData['sleep']} hrs',
                  status: sleepStatus,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.water_drop,
                  label: 'Blood O₂',
                  value: '${healthData['bloodOxygen']}%',
                  status: bloodOxygenStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upcoming Medications
          _buildMedicationsCard(),
          const SizedBox(height: 16),

          // Emergency SOS Button
          _buildSOSCard(),
        ],
      ),
    );
  }

  Widget _buildRingStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF87CEEB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF87CEEB), Color(0xFFC8A8E9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.show_chart, size: 40, color: Color(0xFF2D3748)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ring Status', style: TextStyle(color: Color(0xFF718096))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4F8C8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    healthData['ringConnected'] ? 'Connected' : 'Disconnected',
                    style: const TextStyle(color: Color(0xFF2D3748), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.battery_charging_full, color: Color(0xFF718096)),
                    const SizedBox(width: 8),
                    Text('${healthData['battery']}%',
                        style: const TextStyle(color: Color(0xFF2D3748))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String label,
    required String value,
    required HealthStatus status,
    bool showProgress = false,
    double progress = 0.0,
  }) {
    Color bgColor;
    Color iconColor;

    switch (status.bgColor) {
      case 'bg-[#FAA09A]/40':
        bgColor = const Color(0xFFFAA09A).withOpacity(0.4);
        iconColor = const Color(0xFFd97066);
        break;
      case 'bg-[#F4E87C]/40':
        bgColor = const Color(0xFFF4E87C).withOpacity(0.4);
        iconColor = const Color(0xFFd4b84a);
        break;
      default:
        bgColor = const Color(0xFFB4F8C8).withOpacity(0.4);
        iconColor = const Color(0xFF6fbb8a);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.status != 'normal' ? const Color(0xFFFAA09A) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              if (status.status != 'normal')
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAA09A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Color(0xFF718096), fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: iconColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (showProgress)
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
                const SizedBox(height: 4),
              ],
            ),
          _buildStatusLabel(status),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(HealthStatus status) {
    IconData? icon;
    String label;
    Color color;

    switch (status.status) {
      case 'critical':
        icon = Icons.warning;
        label = 'Critical';
        color = const Color(0xFFd97066);
        break;
      case 'warning':
        icon = Icons.error_outline;
        label = 'Warning';
        color = const Color(0xFFd4b84a);
        break;
      default:
        label = 'Normal';
        color = const Color(0xFF6fbb8a);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 16, color: color),
        if (icon != null) const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildMedicationsCard() {
    final medications = [
      {'name': 'Lisinopril', 'dosage': '10 mg', 'time': '2:00 PM'},
      {'name': 'Vitamin D', 'dosage': '2000 IU', 'time': '6:00 PM'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4E87C), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFd4b84a), size: 24),
              SizedBox(width: 8),
              Text('Upcoming Meds',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...medications.map((med) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4E87C).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name']!,
                    style: const TextStyle(
                        color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(med['dosage']!, style: const TextStyle(color: Color(0xFF718096))),
                const SizedBox(height: 4),
                Text('Due at ${med['time']}',
                    style: const TextStyle(color: Color(0xFF718096))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4E87C),
                      foregroundColor: const Color(0xFF2D3748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Mark Taken'),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSOSCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAA09A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFAA09A), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFAA09A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: Color(0xFFd97066), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Press SOS for immediate help. Emergency contacts will be notified.',
                    style: TextStyle(color: Color(0xFF2D3748)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _handleManualSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAA09A),
                foregroundColor: const Color(0xFF2D3748),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 28),
                  SizedBox(width: 12),
                  Text('SOS Emergency', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HealthStatus {
  final String status;
  final String color;
  final String bgColor;

  HealthStatus(this.status, this.color, this.bgColor);
}

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({Key? key}) : super(key: key);

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final heartRateData = [
    {'time': '6AM', 'bpm': 68.0},
    {'time': '9AM', 'bpm': 72.0},
    {'time': '12PM', 'bpm': 75.0},
    {'time': '3PM', 'bpm': 70.0},
    {'time': '6PM', 'bpm': 74.0},
    {'time': '9PM', 'bpm': 69.0},
  ];

  final stepsData = [
    {'day': 'Mon', 'steps': 5234.0},
    {'day': 'Tue', 'steps': 6721.0},
    {'day': 'Wed', 'steps': 4856.0},
    {'day': 'Thu', 'steps': 7123.0},
    {'day': 'Fri', 'steps': 5967.0},
    {'day': 'Sat', 'steps': 4234.0},
    {'day': 'Sun', 'steps': 3821.0},
  ];

  final sleepData = [
    {'day': 'Mon', 'hours': 7.2},
    {'day': 'Tue', 'hours': 6.8},
    {'day': 'Wed', 'hours': 7.5},
    {'day': 'Thu', 'hours': 7.0},
    {'day': 'Fri', 'hours': 6.5},
    {'day': 'Sat', 'hours': 8.2},
    {'day': 'Sun', 'hours': 7.5},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2D3748),
            unselectedLabelColor: const Color(0xFF718096),
            indicatorColor: const Color(0xFF87CEEB),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Charts'),
              Tab(text: 'Health Alerts'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChartsTab(),
              _buildHealthAlertsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Heart Rate Chart
          _buildChartCard(
            icon: Icons.favorite,
            iconColor: const Color(0xFFFAA09A),
            title: 'Heart Rate Today',
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: _buildLineChart(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAA09A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Average: 72 BPM',
                          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Range: 68-75 (Normal)',
                          style: TextStyle(color: Color(0xFF718096))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Steps Chart
          _buildChartCard(
            icon: Icons.directions_walk,
            iconColor: const Color(0xFFB4F8C8),
            title: 'Steps This Week',
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: _buildStepsBarChart(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4F8C8).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Avg: 5,422 steps',
                          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Goal: 6,000 steps/day',
                          style: TextStyle(color: Color(0xFF2D3748))),
                      SizedBox(height: 4),
                      Text('💡 You need 578 more steps daily to reach your goal',
                          style: TextStyle(color: Color(0xFFd4b84a))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sleep Chart
          _buildChartCard(
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFFC8A8E9),
            title: 'Sleep This Week',
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: _buildSleepBarChart(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A8E9).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avg: 7.2 hrs/night',
                          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Goal: 7-9 hours', style: TextStyle(color: Color(0xFF718096))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Health Insights Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.2),
                  const Color(0xFFC8A8E9).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB).withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_up, size: 28, color: Color(0xFF5ba3c7)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Health Insights',
                          style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text('• Heart rate is healthy',
                          style: TextStyle(color: Color(0xFF718096))),
                      SizedBox(height: 4),
                      Text('• Try 6,000 steps daily',
                          style: TextStyle(color: Color(0xFF718096))),
                      SizedBox(height: 4),
                      Text('• Sleep quality excellent',
                          style: TextStyle(color: Color(0xFF718096))),
                      SizedBox(height: 4),
                      Text('• Stay hydrated', style: TextStyle(color: Color(0xFF718096))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return CustomPaint(
      painter: LineChartPainter(heartRateData),
      child: Container(),
    );
  }

  Widget _buildStepsBarChart() {
    return CustomPaint(
      painter: BarChartPainter(stepsData, const Color(0xFFB4F8C8)),
      child: Container(),
    );
  }

  Widget _buildSleepBarChart() {
    return CustomPaint(
      painter: SleepBarChartPainter(sleepData, const Color(0xFFC8A8E9)),
      child: Container(),
    );
  }

  Widget _buildHealthAlertsTab() {
    final alerts = [
      {
        'id': 1,
        'type': 'warning',
        'metric': 'Heart Rate',
        'value': '105 BPM',
        'message': 'Heart rate elevated above normal range',
        'time': '2 min ago',
      },
      {
        'id': 2,
        'type': 'critical',
        'metric': 'Blood Oxygen',
        'value': '91%',
        'message': 'Blood oxygen below safe threshold - Emergency contacts notified',
        'time': '5 min ago',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Recent Health Alerts Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Color(0xFFd4b84a), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Recent Health Alerts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (alerts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.show_chart, size: 48, color: Color(0xFFB4F8C8)),
                          SizedBox(height: 12),
                          Text('All vitals normal',
                              style: TextStyle(color: Color(0xFF718096))),
                          SizedBox(height: 4),
                          Text('No alerts in the last 24 hours',
                              style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                        ],
                      ),
                    ),
                  )
                else
                  ...alerts.map((alert) {
                    final isCritical = alert['type'] == 'critical';
                    final bgColor = isCritical
                        ? const Color(0xFFFAA09A).withOpacity(0.2)
                        : const Color(0xFFF4E87C).withOpacity(0.2);
                    final borderColor =
                    isCritical ? const Color(0xFFFAA09A) : const Color(0xFFF4E87C);
                    final iconBgColor = isCritical
                        ? const Color(0xFFFAA09A).withOpacity(0.4)
                        : const Color(0xFFF4E87C).withOpacity(0.4);
                    final iconColor =
                    isCritical ? const Color(0xFFd97066) : const Color(0xFFd4b84a);
                    final badgeColor =
                    isCritical ? const Color(0xFFFAA09A) : const Color(0xFFF4E87C);

                    IconData metricIcon;
                    switch (alert['metric']) {
                      case 'Heart Rate':
                        metricIcon = Icons.favorite;
                        break;
                      case 'Blood Oxygen':
                        metricIcon = Icons.water_drop;
                        break;
                      case 'Sleep':
                        metricIcon = Icons.nightlight_round;
                        break;
                      default:
                        metricIcon = Icons.show_chart;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(metricIcon, size: 20, color: iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      alert['metric'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF2D3748),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (alert['type'] as String).toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2D3748),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert['value'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  alert['message'] as String,
                                  style: const TextStyle(color: Color(0xFF718096)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        size: 16, color: Color(0xFF9CA3AF)),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Auto-SOS System Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Color(0xFF5ba3c7), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Auto-SOS System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'CareRing monitors your vitals 24/7. When critical values are detected, you have 30 seconds to respond before automatic SOS is triggered.',
                  style: TextStyle(color: Color(0xFF2D3748)),
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  'Heart Rate Thresholds',
                  ['Warning: <60 or >100 BPM', 'Critical: <40 or >120 BPM'],
                ),
                const SizedBox(height: 8),
                _buildThresholdCard(
                  'Blood Oxygen Thresholds',
                  ['Warning: <94%', 'Critical: <90%'],
                ),
                const SizedBox(height: 8),
                _buildThresholdCard(
                  'Sleep Duration Thresholds',
                  ['Warning: <6 hrs or >9 hrs', 'Critical: <4 hrs or >11 hrs'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
          )),
        ],
      ),
    );
  }
}

// Simple Line Chart Painter
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFAA09A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFFFAA09A)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
    }

    final maxBpm = 80.0;
    final minBpm = 60.0;
    final range = maxBpm - minBpm;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = 40 + (size.width - 60) * i / (data.length - 1);
      final bpm = data[i]['bpm'] as double;
      final y = size.height - (size.height * (bpm - minBpm) / range);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }

    canvas.drawPath(path, paint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final x = 40 + (size.width - 60) * i / (data.length - 1);
      textPainter.text = TextSpan(
        text: data[i]['time'] as String,
        style: const TextStyle(color: Color(0xFF718096), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bar Chart Painter for Steps
class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color barColor;

  BarChartPainter(this.data, this.barColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
    }

    final maxSteps = 8000.0;
    final barWidth = (size.width - 80) / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = 40 + barWidth * i + barWidth * 0.15;
      final steps = data[i]['steps'] as double;
      final barHeight = (size.height - 30) * (steps / maxSteps);
      final y = size.height - 30 - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth * 0.7, barHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final x = 40 + barWidth * i + barWidth * 0.5;
      textPainter.text = TextSpan(
        text: data[i]['day'] as String,
        style: const TextStyle(color: Color(0xFF718096), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bar Chart Painter for Sleep
class SleepBarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color barColor;

  SleepBarChartPainter(this.data, this.barColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
    }

    final maxHours = 10.0;
    final barWidth = (size.width - 80) / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = 40 + barWidth * i + barWidth * 0.15;
      final hours = data[i]['hours'] as double;
      final barHeight = (size.height - 30) * (hours / maxHours);
      final y = size.height - 30 - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth * 0.7, barHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final x = 40 + barWidth * i + barWidth * 0.5;
      textPainter.text = TextSpan(
        text: data[i]['day'] as String,
        style: const TextStyle(color: Color(0xFF718096), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final contacts = [
    {
      'name': 'Sarah Johnson',
      'relationship': 'Daughter',
      'phone': '(555) 123-4567',
      'initials': 'SJ',
      'color': const Color(0xFFEC4899), // pink-500
    },
    {
      'name': 'Dr. Michael Chen',
      'relationship': 'Primary Care',
      'phone': '(555) 987-6543',
      'initials': 'MC',
      'color': const Color(0xFF3B82F6), // blue-500
    },
    {
      'name': 'Robert Williams',
      'relationship': 'Son',
      'phone': '(555) 246-8135',
      'initials': 'RW',
      'color': const Color(0xFF10B981), // green-500
    },
    {
      'name': 'Emergency Services',
      'relationship': '911',
      'phone': '911',
      'initials': '911',
      'color': const Color(0xFFDC2626), // red-600
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2D3748),
            unselectedLabelColor: const Color(0xFF718096),
            indicatorColor: const Color(0xFF87CEEB),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Contacts'),
              Tab(text: 'SOS History'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContactsTab(),
              _buildSOSHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Info Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF5ba3c7), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These contacts get notified when you press SOS. They can see your location.',
                    style: TextStyle(color: Color(0xFF2D3748)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Cards
          ...contacts.map((contact) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: contact['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          contact['initials'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Contact Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact['name'] as String,
                            style: const TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact['relationship'] as String,
                            style: const TextStyle(color: Color(0xFF718096)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact['phone'] as String,
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB4F8C8),
                          foregroundColor: const Color(0xFF2D3748),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 24),
                            SizedBox(width: 8),
                            Text('Call', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D3748),
                          side: const BorderSide(
                            color: Color(0xFF87CEEB),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 24),
                            SizedBox(width: 8),
                            Text('Share Location', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

          // Add Contact Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D3748),
                  side: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 24),
                    SizedBox(width: 8),
                    Text('Add Contact', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fall Detection Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF5ba3c7), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Fall Detection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'CareRing detects falls. If you don\'t respond in 60 seconds, contacts are notified automatically.',
                  style: TextStyle(color: Color(0xFF2D3748)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF6fbb8a),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSHistoryTab() {
    final sosEvents = [
      {
        'id': 1,
        'date': 'Today',
        'time': '2:34 PM',
        'trigger': 'automatic',
        'reason': 'Blood oxygen dropped to 89%',
        'status': 'resolved',
        'contactsNotified': 4,
        'location': '123 Main St, Boston MA',
      },
      {
        'id': 2,
        'date': 'Yesterday',
        'time': '11:23 AM',
        'trigger': 'automatic',
        'reason': 'Heart rate exceeded 125 BPM',
        'status': 'resolved',
        'contactsNotified': 4,
        'location': 'Home',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // SOS Alert History Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Color(0xFFd4b84a), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'SOS Alert History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sosEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text('No SOS alerts',
                              style: TextStyle(color: Color(0xFF718096))),
                          SizedBox(height: 4),
                          Text('Your emergency history will appear here',
                              style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                        ],
                      ),
                    ),
                  )
                else
                  ...sosEvents.map((event) {
                    final isAutomatic = event['trigger'] == 'automatic';
                    final isResolved = event['status'] == 'resolved';
                    final iconBgColor = isAutomatic
                        ? const Color(0xFFF4E87C).withOpacity(0.4)
                        : const Color(0xFFFAA09A).withOpacity(0.4);
                    final iconColor =
                    isAutomatic ? const Color(0xFFd4b84a) : const Color(0xFFd97066);
                    final triggerBadgeColor =
                    isAutomatic ? const Color(0xFFF4E87C) : const Color(0xFFFAA09A);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.warning, size: 20, color: iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${event['date']} at ${event['time']}',
                                            style: const TextStyle(
                                              color: Color(0xFF2D3748),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: triggerBadgeColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isAutomatic ? 'AUTO' : 'MANUAL',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF2D3748),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isResolved
                                              ? const Color(0xFFB4F8C8)
                                              : const Color(0xFFFAA09A),
                                        ),
                                      ),
                                      child: Text(
                                        event['status'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isResolved
                                              ? const Color(0xFF6fbb8a)
                                              : const Color(0xFFd97066),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  event['reason'] as String,
                                  style: const TextStyle(color: Color(0xFF2D3748)),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.phone,
                                            size: 16, color: Color(0xFF718096)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${event['contactsNotified']} contacts notified',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF718096),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Color(0xFF718096)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            event['location'] as String,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF718096),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Response Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Response Info',
                  style: TextStyle(
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• SOS alerts sent to all contacts via SMS, app notification, and phone call',
                  style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Your location is shared automatically',
                  style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Medical information shared with responders',
                  style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• 30-second cancel window for auto-triggered alerts',
                  style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Map<String, dynamic>> medications = [
    {
      'id': 1,
      'name': 'Lisinopril',
      'dosage': '10 mg',
      'time': '8:00 AM',
      'scheduledTime': '8:00 AM',
      'frequency': 'Daily',
      'taken': true,
      'color': const Color(0xFF3B82F6), // blue-500
    },
    {
      'id': 2,
      'name': 'Metformin',
      'dosage': '500 mg',
      'time': '8:00 AM & 6:00 PM',
      'scheduledTime': '8:00 AM & 6:00 PM',
      'frequency': 'Twice daily',
      'taken': false,
      'color': const Color(0xFF10B981), // green-500
    },
    {
      'id': 3,
      'name': 'Atorvastatin',
      'dosage': '20 mg',
      'time': '9:00 PM',
      'scheduledTime': '9:00 PM',
      'frequency': 'Daily',
      'taken': false,
      'color': const Color(0xFF8B5CF6), // purple-500
    },
    {
      'id': 4,
      'name': 'Vitamin D',
      'dosage': '2000 IU',
      'time': '8:00 AM',
      'scheduledTime': '8:00 AM',
      'frequency': 'Daily',
      'taken': true,
      'color': const Color(0xFFEAB308), // yellow-500
    },
    {
      'id': 5,
      'name': 'Aspirin',
      'dosage': '81 mg',
      'time': '8:00 AM',
      'scheduledTime': '8:00 AM',
      'frequency': 'Daily',
      'taken': true,
      'color': const Color(0xFFEF4444), // red-500
    },
  ];

  void _toggleMedication(int id) {
    setState(() {
      final index = medications.indexWhere((med) => med['id'] == id);
      if (index != -1) {
        medications[index]['taken'] = !medications[index]['taken'];
      }
    });
  }

  int get _takenToday => medications.where((med) => med['taken'] == true).length;
  int get _totalMeds => medications.length;

  MedicationStatus _getMedicationStatus(String scheduledTime, bool taken) {
    if (taken) return MedicationStatus('taken', 'Taken');

    // Simple time comparison - in real app, use proper date/time parsing
    final now = DateTime.now();
    final currentHour = now.hour;

    // Parse scheduled time (simplified)
    if (scheduledTime.contains('8:00 AM')) {
      if (currentHour >= 8 && currentHour < 9) {
        return MedicationStatus('due', 'Due Now');
      } else if (currentHour >= 9) {
        return MedicationStatus('overdue', 'Overdue');
      }
    } else if (scheduledTime.contains('9:00 PM')) {
      if (currentHour >= 21) {
        return MedicationStatus('due', 'Due Now');
      }
    }

    return MedicationStatus('upcoming', 'Upcoming');
  }

  @override
  Widget build(BuildContext context) {
    final overdueMeds = medications.where((med) {
      if (med['taken'] == true) return false;
      final status = _getMedicationStatus(med['scheduledTime'], med['taken']);
      return status.status == 'overdue';
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Overdue Alert
          if (overdueMeds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAA09A).withOpacity(0.2),
                border: Border.all(color: const Color(0xFFFAA09A), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFd97066), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ ${overdueMeds.length} medication${overdueMeds.length > 1 ? 's' : ''} overdue by more than 30 minutes!',
                      style: const TextStyle(
                        color: Color(0xFFd97066),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.2),
                  const Color(0xFFC8A8E9).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(color: Color(0xFF718096)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_takenToday of $_totalMeds taken',
                          style: const TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF87CEEB),
                          width: 8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${((_takenToday / _totalMeds) * 100).round()}%',
                          style: const TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _takenToday == _totalMeds
                        ? const Color(0xFFB4F8C8).withOpacity(0.3)
                        : const Color(0xFFF4E87C).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _takenToday == _totalMeds
                          ? const Color(0xFFB4F8C8)
                          : const Color(0xFFF4E87C),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _takenToday == _totalMeds
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: _takenToday == _totalMeds
                            ? const Color(0xFF6fbb8a)
                            : const Color(0xFFd4b84a),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _takenToday == _totalMeds
                              ? 'Great! All meds taken today.'
                              : '${_totalMeds - _takenToday} medication(s) remaining',
                          style: TextStyle(
                            color: _takenToday == _totalMeds
                                ? const Color(0xFF6fbb8a)
                                : const Color(0xFFd4b84a),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Medications List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medication, color: Color(0xFFC8A8E9), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Today\'s Schedule',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...medications.map((med) {
                  final medStatus = _getMedicationStatus(
                    med['scheduledTime'],
                    med['taken'],
                  );
                  final isOverdue = medStatus.status == 'overdue';
                  final isDue = medStatus.status == 'due';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: med['taken'] ? Colors.grey.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: med['taken']
                            ? Colors.grey.shade300
                            : isOverdue
                            ? const Color(0xFFFAA09A)
                            : isDue
                            ? const Color(0xFFF4E87C)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: med['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            if (isOverdue && !med['taken'])
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFAA09A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      med['name'],
                                      style: TextStyle(
                                        color: const Color(0xFF2D3748),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: med['taken']
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (med['taken'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB4F8C8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 16, color: Color(0xFF2D3748)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Taken',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!med['taken'] && isOverdue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAA09A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.warning,
                                              size: 16, color: Color(0xFF2D3748)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Overdue',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!med['taken'] && isDue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4E87C),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.schedule,
                                              size: 16, color: Color(0xFF2D3748)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Due Now',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med['dosage'],
                                style: const TextStyle(color: Color(0xFF718096)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      size: 20, color: Color(0xFF718096)),
                                  const SizedBox(width: 8),
                                  Text(
                                    med['time'],
                                    style: const TextStyle(color: Color(0xFF718096)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med['frequency'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF718096),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => _toggleMedication(med['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: med['taken']
                                        ? Colors.white
                                        : const Color(0xFF87CEEB),
                                    foregroundColor: const Color(0xFF2D3748),
                                    side: med['taken']
                                        ? BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    )
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    med['taken']
                                        ? 'Mark Not Taken'
                                        : 'Mark Taken',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add Medication Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D3748),
                  side: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 24),
                    SizedBox(width: 8),
                    Text('Add Medication', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reminder Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF87CEEB), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule, color: Color(0xFF5ba3c7), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReminderItem('Ring Vibration', 'On'),
                const SizedBox(height: 12),
                _buildReminderItem('Phone Alert', 'On'),
                const SizedBox(height: 12),
                _buildReminderItem('Reminder Time', '15 min before', isBadge: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String label, String value, {bool isBadge = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF2D3748)),
          ),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB4F8C8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(color: Color(0xFF718096)),
            ),
        ],
      ),
    );
  }
}

class MedicationStatus {
  final String status;
  final String label;

  MedicationStatus(this.status, this.label);
}