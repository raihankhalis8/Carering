import 'package:flutter/material.dart';
import 'dart:async';

// Models
class HealthData {
  final int heartRate;
  final int bloodOxygen;
  final int steps;
  final double sleep;

  HealthData({
    required this.heartRate,
    required this.bloodOxygen,
    required this.steps,
    required this.sleep,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthData &&
              runtimeType == other.runtimeType &&
              heartRate == other.heartRate &&
              bloodOxygen == other.bloodOxygen &&
              steps == other.steps &&
              sleep == other.sleep;

  @override
  int get hashCode =>
      heartRate.hashCode ^
      bloodOxygen.hashCode ^
      steps.hashCode ^
      sleep.hashCode;
}

class HealthAlert {
  final String type; // 'critical' or 'warning'
  final String metric;
  final num value;
  final String message;
  final DateTime timestamp;

  HealthAlert({
    required this.type,
    required this.metric,
    required this.value,
    required this.message,
    required this.timestamp,
  });
}

class HealthThreshold {
  final num? min;
  final num? max;

  HealthThreshold({this.min, this.max});
}

// Health Thresholds
class HealthThresholds {
  static final heartRate = {
    'critical': HealthThreshold(min: 40, max: 120),
    'warning': HealthThreshold(min: 50, max: 100),
  };

  static final bloodOxygen = {
    'critical': HealthThreshold(min: 90),
    'warning': HealthThreshold(min: 94),
  };

  static final sleep = {
    'critical': HealthThreshold(min: 4, max: 11),
    'warning': HealthThreshold(min: 6, max: 9),
  };
}

// Health Status Result
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

// Health Monitor Widget
class HealthMonitor extends StatefulWidget {
  final HealthData healthData;
  final VoidCallback onSOSTriggered;

  const HealthMonitor({
    Key? key,
    required this.healthData,
    required this.onSOSTriggered,
  }) : super(key: key);

  @override
  State<HealthMonitor> createState() => _HealthMonitorState();
}

class _HealthMonitorState extends State<HealthMonitor> {
  final List<HealthAlert> _alerts = [];
  DateTime _lastCheckTime = DateTime.now();
  Timer? _sosTimer;
  HealthData? _previousHealthData;

  @override
  void initState() {
    super.initState();
    _previousHealthData = widget.healthData;
    _checkHealthMetrics(widget.healthData);
  }

  @override
  void didUpdateWidget(HealthMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only check if health data actually changed
    if (widget.healthData != _previousHealthData) {
      _previousHealthData = widget.healthData;
      _checkHealthMetrics(widget.healthData);
    }
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  List<HealthAlert> _checkHealthMetrics(HealthData data) {
    final newAlerts = <HealthAlert>[];

    // Check Heart Rate
    if (data.heartRate < HealthThresholds.heartRate['critical']!.min! ||
        data.heartRate > HealthThresholds.heartRate['critical']!.max!) {
      newAlerts.add(HealthAlert(
        type: 'critical',
        metric: 'Heart Rate',
        value: data.heartRate,
        message:
        'Critical: Heart rate at ${data.heartRate} BPM (Normal: 60-100)',
        timestamp: DateTime.now(),
      ));
    } else if (data.heartRate < HealthThresholds.heartRate['warning']!.min! ||
        data.heartRate > HealthThresholds.heartRate['warning']!.max!) {
      newAlerts.add(HealthAlert(
        type: 'warning',
        metric: 'Heart Rate',
        value: data.heartRate,
        message: 'Warning: Heart rate at ${data.heartRate} BPM',
        timestamp: DateTime.now(),
      ));
    }

    // Check Blood Oxygen
    if (data.bloodOxygen < HealthThresholds.bloodOxygen['critical']!.min!) {
      newAlerts.add(HealthAlert(
        type: 'critical',
        metric: 'Blood Oxygen',
        value: data.bloodOxygen,
        message:
        'Critical: Blood oxygen at ${data.bloodOxygen}% (Normal: 95-100%)',
        timestamp: DateTime.now(),
      ));
    } else if (data.bloodOxygen < HealthThresholds.bloodOxygen['warning']!.min!) {
      newAlerts.add(HealthAlert(
        type: 'warning',
        metric: 'Blood Oxygen',
        value: data.bloodOxygen,
        message: 'Warning: Blood oxygen at ${data.bloodOxygen}%',
        timestamp: DateTime.now(),
      ));
    }

    // Check Sleep
    if (data.sleep < HealthThresholds.sleep['critical']!.min!) {
      newAlerts.add(HealthAlert(
        type: 'critical',
        metric: 'Sleep',
        value: data.sleep,
        message:
        'Critical: Only ${data.sleep} hours of sleep (Recommended: 7-9 hours)',
        timestamp: DateTime.now(),
      ));
    } else if (data.sleep > HealthThresholds.sleep['critical']!.max!) {
      newAlerts.add(HealthAlert(
        type: 'critical',
        metric: 'Sleep',
        value: data.sleep,
        message:
        'Critical: Excessive sleep at ${data.sleep} hours (May indicate health issues)',
        timestamp: DateTime.now(),
      ));
    } else if (data.sleep < HealthThresholds.sleep['warning']!.min!) {
      newAlerts.add(HealthAlert(
        type: 'warning',
        metric: 'Sleep',
        value: data.sleep,
        message: 'Warning: Insufficient sleep - only ${data.sleep} hours',
        timestamp: DateTime.now(),
      ));
    } else if (data.sleep > HealthThresholds.sleep['warning']!.max!) {
      newAlerts.add(HealthAlert(
        type: 'warning',
        metric: 'Sleep',
        value: data.sleep,
        message: 'Warning: Long sleep duration - ${data.sleep} hours',
        timestamp: DateTime.now(),
      ));
    }

    if (newAlerts.isNotEmpty) {
      setState(() {
        _alerts.insertAll(0, newAlerts);
        if (_alerts.length > 10) {
          _alerts.removeRange(10, _alerts.length);
        }
      });

      // Show notifications
      _showAlertNotifications(newAlerts);

      // Auto-trigger SOS for critical alerts
      final hasCriticalAlert = newAlerts.any((alert) => alert.type == 'critical');
      if (hasCriticalAlert) {
        _scheduleAutoSOS();
      }
    }

    setState(() {
      _lastCheckTime = DateTime.now();
    });

    return newAlerts;
  }

  void _showAlertNotifications(List<HealthAlert> alerts) {
    for (final alert in alerts) {
      if (alert.type == 'critical') {
        _showCriticalAlert(alert);
      } else {
        _showWarningAlert(alert);
      }
    }
  }

  void _showCriticalAlert(HealthAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Emergency contacts will be notified',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFd97066),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Call 911',
          textColor: Colors.white,
          onPressed: widget.onSOSTriggered,
        ),
      ),
    );
  }

  void _showWarningAlert(HealthAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFd4b84a),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _scheduleAutoSOS() {
    // Cancel any existing timer
    _sosTimer?.cancel();

    // Schedule automatic SOS after 30 seconds
    _sosTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _showAutoSOSDialog();
        widget.onSOSTriggered();
      }
    });
  }

  void _showAutoSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Color(0xFFd97066)),
            SizedBox(width: 8),
            Text('Automatic SOS Alert Triggered!'),
          ],
        ),
        content: const Text(
          'Emergency contacts have been notified of your health status.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS cancelled'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("I'm OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is a monitoring component without UI
    return const SizedBox.shrink();
  }
}

// Helper function to get health status
HealthStatus getHealthStatus(String metric, num value) {
  switch (metric) {
    case 'heartRate':
      final hr = value as int;
      if (hr < HealthThresholds.heartRate['critical']!.min! ||
          hr > HealthThresholds.heartRate['critical']!.max!) {
        return HealthStatus(
          status: 'critical',
          color: const Color(0xFFd97066),
          bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
        );
      } else if (hr < HealthThresholds.heartRate['warning']!.min! ||
          hr > HealthThresholds.heartRate['warning']!.max!) {
        return HealthStatus(
          status: 'warning',
          color: const Color(0xFFd4b84a),
          bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
        );
      }
      return HealthStatus(
        status: 'normal',
        color: const Color(0xFF6fbb8a),
        bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      );

    case 'bloodOxygen':
      final oxygen = value as int;
      if (oxygen < HealthThresholds.bloodOxygen['critical']!.min!) {
        return HealthStatus(
          status: 'critical',
          color: const Color(0xFFd97066),
          bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
        );
      } else if (oxygen < HealthThresholds.bloodOxygen['warning']!.min!) {
        return HealthStatus(
          status: 'warning',
          color: const Color(0xFFd4b84a),
          bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
        );
      }
      return HealthStatus(
        status: 'normal',
        color: const Color(0xFF6fbb8a),
        bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      );

    case 'sleep':
      final sleep = value as double;
      if (sleep < HealthThresholds.sleep['critical']!.min! ||
          sleep > HealthThresholds.sleep['critical']!.max!) {
        return HealthStatus(
          status: 'critical',
          color: const Color(0xFFd97066),
          bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
        );
      } else if (sleep < HealthThresholds.sleep['warning']!.min! ||
          sleep > HealthThresholds.sleep['warning']!.max!) {
        return HealthStatus(
          status: 'warning',
          color: const Color(0xFFd4b84a),
          bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
        );
      }
      return HealthStatus(
        status: 'normal',
        color: const Color(0xFF6fbb8a),
        bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      );

    default:
      return HealthStatus(
        status: 'normal',
        color: const Color(0xFF6fbb8a),
        bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      );
  }
}

// Example usage in Dashboard or other parent widget:
/*
class DashboardWithMonitor extends StatefulWidget {
  @override
  State<DashboardWithMonitor> createState() => _DashboardWithMonitorState();
}

class _DashboardWithMonitorState extends State<DashboardWithMonitor> {
  HealthData healthData = HealthData(
    heartRate: 72,
    bloodOxygen: 98,
    steps: 4234,
    sleep: 7.5,
  );

  void handleSOSTriggered() {
    print('🚨 SOS TRIGGERED - Emergency contacts notified!');
    // Handle SOS activation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main dashboard content
          YourDashboardContent(),

          // Invisible health monitor
          HealthMonitor(
            healthData: healthData,
            onSOSTriggered: handleSOSTriggered,
          ),
        ],
      ),
    );
  }
}
*/

