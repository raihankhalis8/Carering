import 'package:flutter/material.dart';
import 'dart:async';

// Models
class HealthData {
  final int heartRate;
  final int steps;
  final int stepsGoal;
  final double sleep;
  final int bloodOxygen;
  final int battery;
  final bool ringConnected;

  HealthData({
    required this.heartRate,
    required this.steps,
    required this.stepsGoal,
    required this.sleep,
    required this.bloodOxygen,
    required this.battery,
    required this.ringConnected,
  });

  HealthData copyWith({
    int? heartRate,
    int? steps,
    int? stepsGoal,
    double? sleep,
    int? bloodOxygen,
    int? battery,
    bool? ringConnected,
  }) {
    return HealthData(
      heartRate: heartRate ?? this.heartRate,
      steps: steps ?? this.steps,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sleep: sleep ?? this.sleep,
      bloodOxygen: bloodOxygen ?? this.bloodOxygen,
      battery: battery ?? this.battery,
      ringConnected: ringConnected ?? this.ringConnected,
    );
  }
}

class HealthStatus {
  final String status; // 'normal', 'warning', 'critical'
  final Color color;
  final Color bgColor;

  HealthStatus({
    required this.status,
    required this.color,
    required this.bgColor,
  });
}

class UpcomingMedication {
  final int id;
  final String name;
  final String dosage;
  final String time;

  UpcomingMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
  });
}

// Health Status Helper
HealthStatus getHealthStatus(String type, num value) {
  if (type == 'heartRate') {
    final hr = value as int;
    if (hr < 50 || hr > 120) {
      return HealthStatus(
        status: 'critical',
        color: const Color(0xFFd97066),
        bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
      );
    } else if (hr < 60 || hr > 100) {
      return HealthStatus(
        status: 'warning',
        color: const Color(0xFFd4b84a),
        bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
      );
    }
  } else if (type == 'bloodOxygen') {
    final oxygen = value as int;
    if (oxygen < 90) {
      return HealthStatus(
        status: 'critical',
        color: const Color(0xFFd97066),
        bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
      );
    } else if (oxygen < 95) {
      return HealthStatus(
        status: 'warning',
        color: const Color(0xFFd4b84a),
        bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
      );
    }
  } else if (type == 'sleep') {
    final sleep = value as double;
    if (sleep < 5) {
      return HealthStatus(
        status: 'critical',
        color: const Color(0xFFd97066),
        bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
      );
    } else if (sleep < 6.5) {
      return HealthStatus(
        status: 'warning',
        color: const Color(0xFFd4b84a),
        bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
      );
    }
  }

  return HealthStatus(
    status: 'normal',
    color: const Color(0xFF6fbb8a),
    bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
  );
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late HealthData _healthData;
  bool _sosActive = false;
  String _sosTrigger = 'manual';
  String _sosReason = '';
  Timer? _healthUpdateTimer;

  // Mock medication data
  final List<UpcomingMedication> _upcomingMeds = [
    UpcomingMedication(
      id: 1,
      name: 'Vitamin D',
      dosage: '1000 IU',
      time: '09:00 AM',
    ),
    UpcomingMedication(
      id: 2,
      name: 'Blood Pressure Med',
      dosage: '10 mg',
      time: '02:00 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _healthData = HealthData(
      heartRate: 72,
      steps: 4234,
      stepsGoal: 6000,
      sleep: 7.5,
      bloodOxygen: 98,
      battery: 65,
      ringConnected: true,
    );

    // Simulate real-time health data updates
    _healthUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _healthData = _healthData.copyWith(
          heartRate: _healthData.heartRate + (DateTime.now().millisecond % 7 - 3),
          bloodOxygen: (_healthData.bloodOxygen + (DateTime.now().millisecond % 3 - 1))
              .clamp(88, 100),
          steps: _healthData.steps + (DateTime.now().millisecond % 50),
        );
      });
    });
  }

  @override
  void dispose() {
    _healthUpdateTimer?.cancel();
    super.dispose();
  }

  void _handleManualSOS() {
    setState(() {
      _sosTrigger = 'manual';
      _sosReason = 'Manual emergency activation';
      _sosActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.phone, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Emergency SOS Activated!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Contacting emergency services...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _handleSOSCancel() {
    setState(() {
      _sosActive = false;
      _sosReason = '';
    });
  }

  void _handleMarkTaken(int medId) {
    setState(() {
      _upcomingMeds.removeWhere((med) => med.id == medId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication marked as taken!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heartRateStatus = getHealthStatus('heartRate', _healthData.heartRate);
    final bloodOxygenStatus = getHealthStatus('bloodOxygen', _healthData.bloodOxygen);
    final sleepStatus = getHealthStatus('sleep', _healthData.sleep);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOS Status Alert
              if (_sosActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAA09A).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFFFAA09A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: const Color(0xFFd97066),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🚨 SOS ACTIVE - Emergency contacts notified!',
                          style: TextStyle(
                            color: const Color(0xFFd97066),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ring Status
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFFC8A8E9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.black87,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ring Status',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB4F8C8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _healthData.ringConnected
                                    ? 'Connected'
                                    : 'Disconnected',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.battery_full,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_healthData.battery}%',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.95,
                children: [
                  // Heart Rate Card
                  _buildHealthCard(
                    icon: Icons.favorite,
                    label: 'Heart Rate',
                    value: '${_healthData.heartRate} BPM',
                    status: heartRateStatus,
                  ),

                  // Steps Card
                  _buildStepsCard(),

                  // Sleep Card
                  _buildHealthCard(
                    icon: Icons.bedtime,
                    label: 'Sleep',
                    value: '${_healthData.sleep} hrs',
                    status: sleepStatus,
                  ),

                  // Blood Oxygen Card
                  _buildHealthCard(
                    icon: Icons.water_drop,
                    label: 'Blood O₂',
                    value: '${_healthData.bloodOxygen}%',
                    status: bloodOxygenStatus,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Medication Reminders
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFF4E87C),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.alarm,
                            color: const Color(0xFFd4b84a),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Upcoming Meds',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_upcomingMeds.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  'No upcoming medications',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All medications for today have been taken!',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._upcomingMeds.map((med) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4E87C).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.name,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med.dosage,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Due at ${med.time}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => _handleMarkTaken(med.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFFF4E87C),
                                    foregroundColor: Colors.grey[800],
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Mark Taken',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Emergency SOS Button
              Card(
                elevation: 8,
                color: const Color(0xFFFAA09A).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFFAA09A),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFFAA09A),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFFd97066),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Press SOS for immediate help. Emergency contacts will be notified.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _handleManualSOS,
                          icon: const Icon(Icons.phone, size: 28),
                          label: const Text(
                            'SOS Emergency',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFAA09A),
                            foregroundColor: Colors.grey[800],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String label,
    required String value,
    required HealthStatus status,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: status.status != 'normal'
            ? const BorderSide(color: Color(0xFFFAA09A), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: status.color,
                    size: 32,
                  ),
                ),
                if (status.status != 'normal')
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAA09A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: status.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status.status == 'critical')
                  Icon(Icons.warning, size: 16, color: status.color)
                else if (status.status == 'warning')
                  Icon(Icons.info_outline, size: 16, color: status.color),
                if (status.status != 'normal') const SizedBox(width: 4),
                Text(
                  status.status == 'critical'
                      ? 'Critical'
                      : status.status == 'warning'
                      ? 'Warning'
                      : label == 'Sleep'
                      ? 'Good'
                      : label == 'Blood O₂'
                      ? 'Optimal'
                      : 'Normal',
                  style: TextStyle(
                    color: status.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    final progress = (_healthData.steps / _healthData.stepsGoal).clamp(0.0, 1.0);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB4F8C8).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk,
                color: Color(0xFF6fbb8a),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Steps',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _healthData.steps.toString(),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6fbb8a),
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

