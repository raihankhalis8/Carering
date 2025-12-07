import 'package:flutter/material.dart';
import 'dart:math';

// Models
class MedicationModel {
  final int id;
  final String name;
  final String dosage;
  final String time;
  final String scheduledTime;
  final String frequency;
  final bool taken;
  final Color color;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.scheduledTime,
    required this.frequency,
    required this.taken,
    required this.color,
  });

  MedicationModel copyWith({
    int? id,
    String? name,
    String? dosage,
    String? time,
    String? scheduledTime,
    String? frequency,
    bool? taken,
    Color? color,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      taken: taken ?? this.taken,
      color: color ?? this.color,
    );
  }
}

// Medication Status (from previous conversion)
class MedicationStatus {
  final String status;
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

// Helper function (simplified version)
MedicationStatus getMedicationStatus(String scheduledTime, bool taken) {
  if (taken) {
    return MedicationStatus(
      status: 'taken',
      color: const Color(0xFF6fbb8a),
      bgColor: const Color(0xFFB4F8C8).withOpacity(0.4),
      message: 'Taken',
    );
  }
  // Simplified - in real app, parse time and compare
  return MedicationStatus(
    status: 'upcoming',
    color: Colors.grey[600]!,
    bgColor: Colors.grey[100]!,
    message: 'Upcoming',
  );
}

class Medications extends StatefulWidget {
  const Medications({Key? key}) : super(key: key);

  @override
  State<Medications> createState() => _MedicationsState();
}

class _MedicationsState extends State<Medications> {
  bool _showAddMedication = false;
  int? _editingColorMedId;
  final Set<int> _overdueAlerts = {};

  List<MedicationModel> _medications = [
    MedicationModel(
      id: 1,
      name: 'Aspirin',
      dosage: '100 mg',
      time: '08:00 AM',
      scheduledTime: '8:00 AM',
      frequency: 'Daily',
      taken: false,
      color: const Color(0xFF3b82f6),
    ),
    MedicationModel(
      id: 2,
      name: 'Vitamin D',
      dosage: '1000 IU',
      time: '12:00 PM',
      scheduledTime: '12:00 PM',
      frequency: 'Daily',
      taken: true,
      color: const Color(0xFF22c55e),
    ),
    MedicationModel(
      id: 3,
      name: 'Blood Pressure Med',
      dosage: '10 mg',
      time: '06:00 PM',
      scheduledTime: '6:00 PM',
      frequency: 'Twice daily',
      taken: false,
      color: const Color(0xFFa855f7),
    ),
  ];

  void _handleOverdueAlert(int medicationId) {
    setState(() {
      _overdueAlerts.add(medicationId);
    });
  }

  void _toggleMedication(int id) {
    setState(() {
      final index = _medications.indexWhere((med) => med.id == id);
      if (index != -1) {
        _medications[index] = _medications[index].copyWith(
          taken: !_medications[index].taken,
        );
        _overdueAlerts.remove(id);
      }
    });
  }

  void _handleAddMedication(MedicationModel medication) {
    setState(() {
      _medications.add(medication);
      _showAddMedication = false;
    });
  }

  void _updateMedicationColor(int medId, Color newColor) {
    setState(() {
      final index = _medications.indexWhere((med) => med.id == medId);
      if (index != -1) {
        _medications[index] = _medications[index].copyWith(color: newColor);
      }
      _editingColorMedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddMedication) {
      return _AddMedicationScreen(
        onBack: () => setState(() => _showAddMedication = false),
        onSave: _handleAddMedication,
      );
    }

    final takenToday = _medications.where((med) => med.taken).length;
    final totalMeds = _medications.length;
    final overdueMeds = _medications.where((med) {
      if (med.taken) return false;
      final status = getMedicationStatus(med.scheduledTime, med.taken);
      return status.status == 'overdue';
    }).toList();

    final progressPercent = totalMeds > 0 ? (takenToday / totalMeds * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Overdue Alert
              if (overdueMeds.isNotEmpty)
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
                          '⚠️ ${overdueMeds.length} medication${overdueMeds.length > 1 ? 's' : ''} overdue by more than 30 minutes!',
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

              // Summary Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF87CEEB).withOpacity(0.2),
                        const Color(0xFFC8A8E9).withOpacity(0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Progress",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$takenToday of $totalMeds taken',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
                                '$progressPercent%',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: takenToday == totalMeds
                              ? const Color(0xFFB4F8C8).withOpacity(0.3)
                              : const Color(0xFFF4E87C).withOpacity(0.3),
                          border: Border.all(
                            color: takenToday == totalMeds
                                ? const Color(0xFFB4F8C8)
                                : const Color(0xFFF4E87C),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              takenToday == totalMeds
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color: takenToday == totalMeds
                                  ? const Color(0xFF6fbb8a)
                                  : const Color(0xFFd4b84a),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                takenToday == totalMeds
                                    ? 'Great! All meds taken today.'
                                    : '${totalMeds - takenToday} medication(s) remaining',
                                style: TextStyle(
                                  color: takenToday == totalMeds
                                      ? const Color(0xFF6fbb8a)
                                      : const Color(0xFFd4b84a),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Medications List
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            color: const Color(0xFFC8A8E9),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Today's Schedule",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._medications.map((med) {
                        final medStatus = getMedicationStatus(
                          med.scheduledTime,
                          med.taken,
                        );
                        final isOverdue = medStatus.status == 'overdue';
                        final isDue = medStatus.status == 'due';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: med.taken ? Colors.grey[50] : Colors.white,
                            border: Border.all(
                              color: med.taken
                                  ? Colors.grey[200]!
                                  : isOverdue
                                  ? const Color(0xFFFAA09A)
                                  : isDue
                                  ? const Color(0xFFF4E87C)
                                  : Colors.grey[200]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Color Circle
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _editingColorMedId = med.id;
                                      });
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: med.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.medication,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  if (isOverdue && !med.taken)
                                    Positioned(
                                      top: -4,
                                      right: -4,
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

                              // Medication Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            med.name,
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              decoration: med.taken
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (med.taken)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB4F8C8),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 14,
                                                  color: Colors.grey[800],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Taken',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (!med.taken && isOverdue)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFAA09A),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.warning,
                                                  size: 14,
                                                  color: Colors.grey[800],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Overdue',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (!med.taken && isDue)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF4E87C),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey[800],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Due Now',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      med.dosage,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          med.time,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      med.frequency,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _toggleMedication(med.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: med.taken
                                              ? Colors.white
                                              : const Color(0xFFB4F8C8),
                                          foregroundColor: Colors.grey[800],
                                          side: med.taken
                                              ? BorderSide(
                                              color: Colors.grey[300]!)
                                              : null,
                                          elevation: med.taken ? 0 : 2,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        child: Text(
                                          med.taken
                                              ? 'Mark Not Taken'
                                              : 'Mark Taken',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
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
              ),
              const SizedBox(height: 16),

              // Add Medication Button
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _showAddMedication = true),
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Add Medication',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(
                          color: Color(0xFF87CEEB),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reminder Settings
              Card(
                elevation: 8,
                color: const Color(0xFF87CEEB).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF87CEEB),
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
                            Icons.access_time,
                            color: const Color(0xFF5ba3c7),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Reminders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReminderItem('Ring Vibration', 'On', true),
                      const SizedBox(height: 8),
                      _buildReminderItem('Phone Alert', 'On', true),
                      const SizedBox(height: 8),
                      _buildReminderItem(
                          'Reminder Time', '15 min before', false),
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

  Widget _buildReminderItem(String title, String value, bool isBadge) {
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
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
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
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

// Simplified Add Medication Screen
class _AddMedicationScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(MedicationModel) onSave;

  const _AddMedicationScreen({
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Add Medication'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Create sample medication
            final newMed = MedicationModel(
              id: Random().nextInt(10000),
              name: 'New Medication',
              dosage: '50 mg',
              time: '10:00 AM',
              scheduledTime: '10:00 AM',
              frequency: 'Daily',
              taken: false,
              color: Colors.blue,
            );
            onSave(newMed);
          },
          child: const Text('Add Sample Medication'),
        ),
      ),
    );
  }
}

