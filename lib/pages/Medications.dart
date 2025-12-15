import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'dart:math';

class Medications extends StatefulWidget {
  const Medications({super.key});

  @override
  State<Medications> createState() => _MedicationsState();
}

class _MedicationsState extends State<Medications> {
  bool _showAddMedication = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final medications = appState.medications;
    final reminderSettings = appState.reminderSettings;

    if (_showAddMedication) {
      return _AddMedicationScreen(
        onBack: () => setState(() => _showAddMedication = false),
        onSave: (medication) {
          appState.addMedication(medication);
          setState(() => _showAddMedication = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }

    final takenToday = medications.where((med) => med.taken).length;
    final totalMeds = medications.length;
    final progressPercent = totalMeds > 0 ? (takenToday / totalMeds * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
              if (medications.isEmpty)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medication,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No medications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first medication below',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
                        ...medications.map((med) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: med.taken ? Colors.grey[50] : Colors.white,
                              border: Border.all(
                                color: med.taken
                                    ? Colors.grey[200]!
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
                                Container(
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  appState.toggleMedicationTaken(med.id),
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
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Medication?'),
                                                  content: Text(
                                                    'Are you sure you want to delete ${med.name}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        appState.deleteMedication(med.id);
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Medication deleted'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      },
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.red,
                                                      ),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
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
                      _buildReminderItem(
                        context,
                        'Ring Vibration',
                        reminderSettings['ringVibration'] ?? true,
                            (value) {
                          final updated = Map<String, dynamic>.from(reminderSettings);
                          updated['ringVibration'] = value;
                          appState.updateReminderSettings(updated);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildReminderItem(
                        context,
                        'Phone Alert',
                        reminderSettings['phoneAlert'] ?? true,
                            (value) {
                          final updated = Map<String, dynamic>.from(reminderSettings);
                          updated['phoneAlert'] = value;
                          appState.updateReminderSettings(updated);
                        },
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

  Widget _buildReminderItem(
      BuildContext context,
      String title,
      bool value,
      Function(bool) onChanged,
      ) {
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6fbb8a),
          ),
        ],
      ),
    );
  }
}

// Add Medication Screen
class _AddMedicationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(MedicationModel) onSave;

  const _AddMedicationScreen({
    required this.onBack,
    required this.onSave,
  });

  @override
  State<_AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<_AddMedicationScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dosageCtrl = TextEditingController();
  String _frequency = 'Daily';
  TimeOfDay? selectedTime;
  Color _selectedColor = const Color(0xFF3b82f6);

  final List<Color> _colorOptions = [
    const Color(0xFF3b82f6), // Blue
    const Color(0xFF22c55e), // Green
    const Color(0xFFa855f7), // Purple
    const Color(0xFFeab308), // Yellow
    const Color(0xFFef4444), // Red
    const Color(0xFFec4899), // Pink
  ];

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _saveMedication() {
    if (nameCtrl.text.isEmpty ||
        dosageCtrl.text.isEmpty ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final formattedTime = selectedTime!.format(context);

    final newMed = MedicationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: nameCtrl.text,
      dosage: dosageCtrl.text,
      time: formattedTime,
      scheduledTime: formattedTime,
      frequency: _frequency,
      taken: false,
      color: _selectedColor,
    );

    widget.onSave(newMed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Add Medication'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Medication Name *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageCtrl,
              decoration: const InputDecoration(
                labelText: "Dosage *",
                hintText: "e.g., 100 mg",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: "Frequency",
                border: OutlineInputBorder(),
              ),
              items: ['Daily', 'Twice daily', 'Three times daily', 'As needed']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTime == null
                          ? "Pick Time *"
                          : selectedTime!.format(context),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Pill Color:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFB4F8C8),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}