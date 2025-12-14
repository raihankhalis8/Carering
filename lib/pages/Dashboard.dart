import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import health monitoring
import '../main.dart';
import 'HealthMonitor.dart';
import 'MedicationMonitor.dart';
import 'SOSAlertSystem.dart';

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
  final String status;
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

class Medication {
  final int id;
  final String name;
  final String dosage;
  final String scheduledTime;
  final bool taken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.scheduledTime,
    required this.taken,
  });
}

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
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late HealthData _healthData;
  bool _sosActive = false;
  String _sosTrigger = 'manual';
  String _sosReason = '';
  Timer? _healthUpdateTimer;

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

  final List<Medication> _medications = [
    Medication(
      id: 1,
      name: 'Vitamin D',
      dosage: '1000 IU',
      scheduledTime: '09:00 AM',
      taken: false,
    ),
    Medication(
      id: 2,
      name: 'Blood Pressure Med',
      dosage: '10 mg',
      scheduledTime: '02:00 PM',
      taken: false,
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
      ringConnected: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHealthDataFromProvider();
    });

    // Update every 5 seconds for frequent refresh
    _healthUpdateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateHealthDataFromProvider();
    });
  }

  void _updateHealthDataFromProvider() {
    print('_updateHealthDataFromProvider start');
    try {
      final deviceState = Provider.of<DeviceState>(context, listen: false);
      print('_updateHealthDataFromProvider deviceState: $deviceState');
      print('_updateHealthDataFromProvider deviceState healthData: ${deviceState.healthData}');
      if (deviceState.healthData != null) {
        setState(() {
          _healthData = deviceState.healthData!;
        });
      } else {
        // Simulate data if no real device connected
        setState(() {
          _healthData = _healthData.copyWith(
            heartRate: (_healthData.heartRate + (DateTime.now().millisecond % 7 - 3)).clamp(60, 100),
            bloodOxygen: (_healthData.bloodOxygen + (DateTime.now().millisecond % 3 - 1)).clamp(90, 100),
            steps: _healthData.steps + (DateTime.now().millisecond % 20),
          );
        });
      }
    } catch (e) {
      print('_updateHealthDataFromProvider exception: $e');
      // Provider not available, continue with simulated data
      setState(() {
        _healthData = _healthData.copyWith(
          heartRate: (_healthData.heartRate + (DateTime.now().millisecond % 7 - 3)).clamp(60, 100),
          bloodOxygen: (_healthData.bloodOxygen + (DateTime.now().millisecond % 3 - 1)).clamp(90, 100),
          steps: _healthData.steps + (DateTime.now().millisecond % 20),
        );
      });
    }
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

  void _handleSOSTriggered() {
    setState(() {
      _sosTrigger = 'automatic';
      _sosReason = 'Critical health values detected';
      _sosActive = true;
    });
  }

  void _handleMedicationOverdue(Medication med) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medication reminder: ${med.name} is overdue!'),
        backgroundColor: const Color(0xFFd97066),
        duration: const Duration(seconds: 5),
      ),
    );
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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _updateHealthDataFromProvider();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Connection Status Banner
                    if (!_healthData.ringConnected)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E87C).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFFF4E87C),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bluetooth_searching,
                              color: const Color(0xFFd4b84a),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '⚠️ Ring not connected',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // SOS Status Alert
                    if (_sosActive)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
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
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '🚨 SOS ACTIVE',
                                style: TextStyle(
                                  color: Color(0xFFd97066),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Ring Status Card
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
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 0,
                              child: Container(
                                width: 60,
                                height: 60,
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
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ring Status',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _healthData.ringConnected
                                          ? const Color(0xFFB4F8C8)
                                          : const Color(0xFFF4E87C),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _healthData.ringConnected
                                          ? 'Connected'
                                          : 'Simulated',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.battery_full,
                                        color: Colors.grey[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${_healthData.battery}%',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 16) / 2;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildHealthCard(
                                icon: Icons.favorite,
                                label: 'Heart Rate',
                                value: '${_healthData.heartRate} BPM',
                                status: heartRateStatus,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStepsCard(),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildHealthCard(
                                icon: Icons.bedtime,
                                label: 'Sleep',
                                value: '${_healthData.sleep} hrs',
                                status: sleepStatus,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildHealthCard(
                                icon: Icons.water_drop,
                                label: 'Blood O₂',
                                value: '${_healthData.bloodOxygen}%',
                                status: bloodOxygenStatus,
                              ),
                            ),
                          ],
                        );
                      },
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.alarm,
                                  color: const Color(0xFFd4b84a),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Upcoming Meds',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_upcomingMeds.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    children: [
                                      Text(
                                        'No upcoming medications',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._upcomingMeds.map((med) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4E87C).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      med.name,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${med.dosage} • Due at ${med.time}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () => _handleMarkTaken(med.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF4E87C),
                                          foregroundColor: Colors.grey[800],
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Mark Taken',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
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
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Press SOS for immediate help',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _handleManualSOS,
                                icon: const Icon(Icons.phone, size: 24),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'SOS Emergency',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // // Health Monitor
          // HealthMonitor(
          //   healthData: HealthData(
          //     heartRate: _healthData.heartRate,
          //     bloodOxygen: _healthData.bloodOxygen,
          //     steps: _healthData.steps,
          //     sleep: _healthData.sleep,
          //   ),
          //   onSOSTriggered: _handleSOSTriggered,
          // ),
          //
          // // Medication Monitor
          // MedicationMonitor(
          //   medications: _medications,
          //   onOverdueAlert: _handleMedicationOverdue,
          // ),

          // SOS Alert System
          if (_sosActive)
            SOSAlertSystem(
              isActive: _sosActive,
              onCancel: _handleSOSCancel,
              trigger: _sosTrigger,
              reason: _sosReason,
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: status.color,
                    size: 28,
                  ),
                ),
                if (status.status != 'normal')
                  Positioned(
                    top: -4,
                    right: -4,
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
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: status.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.status == 'critical')
                  Icon(Icons.warning, size: 14, color: status.color)
                else if (status.status == 'warning')
                  Icon(Icons.info_outline, size: 14, color: status.color),
                if (status.status != 'normal') const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    status.status == 'critical'
                        ? 'Critical'
                        : status.status == 'warning'
                        ? 'Warning'
                        : label == 'Sleep'
                        ? 'Good'
                        : 'Normal',
                    style: TextStyle(
                      color: status.color,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB4F8C8).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk,
                color: Color(0xFF6fbb8a),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Steps',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _healthData.steps.toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6fbb8a),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // DeviceState class for Provider (define in main.dart)
// class DeviceState {
//   HealthData? healthData;
// }