import 'package:flutter/material.dart';
import 'dart:async';

// Models
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Medication &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              dosage == other.dosage &&
              scheduledTime == other.scheduledTime &&
              taken == other.taken;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dosage.hashCode ^
      scheduledTime.hashCode ^
      taken.hashCode;
}

// Medication Status Result
class MedicationStatus {
  final String status; // 'taken', 'upcoming', 'due', 'overdue'
  final Color color;
  final Color bgColor;
  final String message;

  MedicationStatus({
    required this.status,
    required this.color,
    required this.bgColor,
    required this.message,
  });
}

// Helper functions
int parseTimeToMinutes(String timeStr) {
  final regex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
  final match = regex.firstMatch(timeStr);

  if (match == null) return -1;

  int hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  final period = match.group(3)!.toUpperCase();

  if (period == 'PM' && hours != 12) hours += 12;
  if (period == 'AM' && hours == 12) hours = 0;

  return hours * 60 + minutes;
}

int getCurrentMinutes() {
  final now = DateTime.now();
  return now.hour * 60 + now.minute;
}

// Medication Monitor Widget
class MedicationMonitor extends StatefulWidget {
  final List<Medication> medications;
  final Function(Medication) onOverdueAlert;

  const MedicationMonitor({
    Key? key,
    required this.medications,
    required this.onOverdueAlert,
  }) : super(key: key);

  @override
  State<MedicationMonitor> createState() => _MedicationMonitorState();
}

class _MedicationMonitorState extends State<MedicationMonitor> {
  final Set<int> _checkedMedications = {};
  Timer? _checkTimer;
  List<Medication>? _previousMedications;

  @override
  void initState() {
    super.initState();
    _previousMedications = widget.medications;
    _checkOverdueMedications();
    _startMonitoring();
  }

  @override
  void didUpdateWidget(MedicationMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if medications list changed
    if (_medicationsChanged(oldWidget.medications, widget.medications)) {
      _previousMedications = widget.medications;
      _checkOverdueMedications();
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  bool _medicationsChanged(
      List<Medication> oldMeds, List<Medication> newMeds) {
    if (oldMeds.length != newMeds.length) return true;
    for (int i = 0; i < oldMeds.length; i++) {
      if (oldMeds[i] != newMeds[i]) return true;
    }
    return false;
  }

  void _startMonitoring() {
    // Check every minute
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkOverdueMedications();
    });
  }

  void _checkOverdueMedications() {
    final currentMinutes = getCurrentMinutes();

    for (final med in widget.medications) {
      // Skip if already taken
      if (med.taken) {
        _checkedMedications.remove(med.id);
        continue;
      }

      // Skip if already alerted
      if (_checkedMedications.contains(med.id)) {
        continue;
      }

      // Handle medications with multiple times (e.g., "8:00 AM & 6:00 PM")
      final times = med.scheduledTime.split('&').map((t) => t.trim()).toList();

      for (final timeStr in times) {
        final scheduledMinutes = parseTimeToMinutes(timeStr);
        if (scheduledMinutes == -1) continue;

        final minutesOverdue = currentMinutes - scheduledMinutes;

        // Check if medication is overdue by more than 30 minutes
        // and not from yesterday (< 12 hours = 720 minutes)
        if (minutesOverdue > 30 && minutesOverdue < 720) {
          // Mark as checked so we don't alert again
          setState(() {
            _checkedMedications.add(med.id);
          });

          // Show notification
          _showOverdueNotification(med, timeStr);

          // Call the callback
          widget.onOverdueAlert(med);
        }
      }
    }
  }

  void _showOverdueNotification(Medication med, String timeStr) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Medication Reminder: ${med.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'You missed your ${med.dosage} dose scheduled for $timeStr. Please take it now.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFd97066),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is a monitoring component without UI
    return const SizedBox.shrink();
  }
}

// Helper function to get medication status
MedicationStatus getMedicationStatus(String scheduledTime, bool taken) {
  if (taken) {
    return MedicationStatus(
      status: 'taken',
      color: const Color(0xFF6fbb8a),
      bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      message: 'Taken',
    );
  }

  final currentMinutes = getCurrentMinutes();

  // Handle multiple times
  final times = scheduledTime.split('&').map((t) => t.trim()).toList();
  String closestStatus = 'upcoming';
  int closestMinutesDiff = 999999;

  for (final timeStr in times) {
    final scheduledMinutes = parseTimeToMinutes(timeStr);
    if (scheduledMinutes == -1) continue;

    final minutesDiff = currentMinutes - scheduledMinutes;

    if (minutesDiff.abs() < closestMinutesDiff.abs()) {
      closestMinutesDiff = minutesDiff;

      if (minutesDiff > 30) {
        closestStatus = 'overdue';
      } else if (minutesDiff >= -15 && minutesDiff <= 30) {
        closestStatus = 'due';
      } else {
        closestStatus = 'upcoming';
      }
    }
  }

  switch (closestStatus) {
    case 'overdue':
      return MedicationStatus(
        status: 'overdue',
        color: const Color(0xFFd97066),
        bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
        message: 'Overdue!',
      );
    case 'due':
      return MedicationStatus(
        status: 'due',
        color: const Color(0xFFd4b84a),
        bgColor: const Color(0xFFF4E87C).withOpacity(0.4),
        message: 'Due now',
      );
    case 'upcoming':
    default:
      return MedicationStatus(
        status: 'upcoming',
        color: Colors.grey[600]!,
        bgColor: Colors.grey[100]!,
        message: 'Upcoming',
      );
  }
}

// Example usage in parent widget:
/*
class MedicationScreen extends StatefulWidget {
  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Medication> medications = [
    Medication(
      id: 1,
      name: 'Aspirin',
      dosage: '100mg',
      scheduledTime: '8:00 AM',
      taken: false,
    ),
    Medication(
      id: 2,
      name: 'Vitamin D',
      dosage: '1000 IU',
      scheduledTime: '12:00 PM & 6:00 PM',
      taken: false,
    ),
  ];

  void handleOverdueAlert(Medication med) {
    print('⏰ Medication overdue: ${med.name}');
    // Handle overdue medication logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your medication list UI
          YourMedicationList(),

          // Invisible medication monitor
          MedicationMonitor(
            medications: medications,
            onOverdueAlert: handleOverdueAlert,
          ),
        ],
      ),
    );
  }
}
*/

// Widget to display medication status badge
class MedicationStatusBadge extends StatelessWidget {
  final String scheduledTime;
  final bool taken;

  const MedicationStatusBadge({
    Key? key,
    required this.scheduledTime,
    required this.taken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = getMedicationStatus(scheduledTime, taken);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.status == 'overdue')
            const Icon(Icons.warning, size: 14, color: Color(0xFFd97066))
          else if (status.status == 'due')
            const Icon(Icons.access_time, size: 14, color: Color(0xFFd4b84a))
          else if (status.status == 'taken')
              const Icon(Icons.check_circle, size: 14, color: Color(0xFF6fbb8a)),
          if (status.status != 'upcoming') const SizedBox(width: 4),
          Text(
            status.message,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Example of medication card with status
class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onMarkTaken;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.onMarkTaken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                MedicationStatusBadge(
                  scheduledTime: medication.scheduledTime,
                  taken: medication.taken,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              medication.dosage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  medication.scheduledTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (!medication.taken) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onMarkTaken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4F8C8),
                  foregroundColor: Colors.grey[800],
                ),
                child: const Text('Mark as Taken'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

