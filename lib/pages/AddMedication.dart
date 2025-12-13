import 'package:flutter/material.dart';

class Medication {
  final String name;
  final String dosage;
  final String time;
  final String frequency;
  final String notes;
  final Color color;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.notes,
    required this.color,
  });
}

class ColorOption {
  final Color color;
  final String label;

  ColorOption({required this.color, required this.label});
}

class AddMedication extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Medication) onSave;

  const AddMedication({
    super.key,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<AddMedication> createState() => _AddMedicationState();
}

class _AddMedicationState extends State<AddMedication> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay? _selectedTime;
  String _frequency = 'Daily';
  Color _selectedColor = const Color(0xFF3b82f6); // Blue

  final List<ColorOption> _colorOptions = [
    ColorOption(color: const Color(0xFF3b82f6), label: 'Blue'),
    ColorOption(color: const Color(0xFF22c55e), label: 'Green'),
    ColorOption(color: const Color(0xFFa855f7), label: 'Purple'),
    ColorOption(color: const Color(0xFFeab308), label: 'Yellow'),
    ColorOption(color: const Color(0xFFef4444), label: 'Red'),
    ColorOption(color: const Color(0xFFec4899), label: 'Pink'),
    ColorOption(color: const Color(0xFF6366f1), label: 'Indigo'),
    ColorOption(color: const Color(0xFFf97316), label: 'Orange'),
    ColorOption(color: const Color(0xFF14b8a6), label: 'Teal'),
    ColorOption(color: const Color(0xFF06b6d4), label: 'Cyan'),
    ColorOption(color: const Color(0xFF10b981), label: 'Emerald'),
    ColorOption(color: const Color(0xFFf43f5e), label: 'Rose'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final medication = Medication(
        name: _nameController.text,
        dosage: _dosageController.text,
        time: _formatTime(_selectedTime),
        frequency: _frequency,
        notes: _notesController.text,
        color: _selectedColor,
      );

      widget.onSave(medication);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      widget.onBack();
    } else if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 24),
                label: const Text(
                  'Back to Medications',
                  style: TextStyle(fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Main Card
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            color: const Color(0xFFC8A8E9),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Add Medication',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medication Name
                            Text(
                              'Medication Name *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter medication name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF87CEEB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter medication name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Dosage
                            Text(
                              'Dosage *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dosageController,
                              decoration: InputDecoration(
                                hintText: 'e.g., 10 mg, 500 IU',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF87CEEB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter dosage';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Schedule / Time
                            Text(
                              'Schedule / Time *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedTime != null
                                          ? _selectedTime!.format(context)
                                          : 'Select time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedTime != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Frequency
                            Text(
                              'Frequency',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _frequency,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF87CEEB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: [
                                'Daily',
                                'Twice daily',
                                'Three times daily',
                                'As needed',
                                'Weekly',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _frequency = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Pill Color
                            Text(
                              'Pill Color *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.5,
                              ),
                              itemCount: _colorOptions.length,
                              itemBuilder: (context, index) {
                                final colorOption = _colorOptions[index];
                                final isSelected =
                                    _selectedColor == colorOption.color;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = colorOption.color;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorOption.color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                                        width: 4,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.grey[800],
                                          size: 20,
                                        ),
                                      ),
                                    )
                                        : null,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Selected: ${_colorOptions.firstWhere((c) => c.color == _selectedColor).label}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Notes
                            Text(
                              'Notes (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                'Special instructions or reminders...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF87CEEB),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _handleSubmit,
                                icon: const Icon(Icons.medication, size: 24),
                                label: const Text(
                                  'Save Medication',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB4F8C8),
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
}

