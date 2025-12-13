import 'package:flutter/material.dart';

class ColorOption {
  final String value;
  final String label;
  final Color color;

  ColorOption({
    required this.value,
    required this.label,
    required this.color,
  });
}

class EditMedicationColor extends StatefulWidget {
  final int medicationId;
  final String medicationName;
  final String currentColor;
  final Function(int medicationId, String newColor) onSave;

  const EditMedicationColor({
    super.key,
    required this.medicationId,
    required this.medicationName,
    required this.currentColor,
    required this.onSave,
  });

  @override
  State<EditMedicationColor> createState() => _EditMedicationColorState();
}

class _EditMedicationColorState extends State<EditMedicationColor> {
  late String _selectedColor;

  final List<ColorOption> _colorOptions = [
    ColorOption(value: 'bg-blue-500', label: 'Blue', color: const Color(0xFF3b82f6)),
    ColorOption(value: 'bg-green-500', label: 'Green', color: const Color(0xFF22c55e)),
    ColorOption(value: 'bg-purple-500', label: 'Purple', color: const Color(0xFFa855f7)),
    ColorOption(value: 'bg-yellow-500', label: 'Yellow', color: const Color(0xFFeab308)),
    ColorOption(value: 'bg-red-500', label: 'Red', color: const Color(0xFFef4444)),
    ColorOption(value: 'bg-pink-500', label: 'Pink', color: const Color(0xFFec4899)),
    ColorOption(value: 'bg-indigo-500', label: 'Indigo', color: const Color(0xFF6366f1)),
    ColorOption(value: 'bg-orange-500', label: 'Orange', color: const Color(0xFFf97316)),
    ColorOption(value: 'bg-teal-500', label: 'Teal', color: const Color(0xFF14b8a6)),
    ColorOption(value: 'bg-cyan-500', label: 'Cyan', color: const Color(0xFF06b6d4)),
    ColorOption(value: 'bg-emerald-500', label: 'Emerald', color: const Color(0xFF10b981)),
    ColorOption(value: 'bg-rose-500', label: 'Rose', color: const Color(0xFFf43f5e)),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  void _handleSave() {
    widget.onSave(widget.medicationId, _selectedColor);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication color updated!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColorLabel = _colorOptions
        .firstWhere(
          (c) => c.value == _selectedColor,
      orElse: () => _colorOptions[0],
    )
        .label;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: const Color(0xFFC8A8E9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Change Color',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.medicationName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Color Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final colorOption = _colorOptions[index];
                final isSelected = _selectedColor == colorOption.value;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorOption.value;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: colorOption.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.grey[800]! : Colors.grey[200]!,
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
            const SizedBox(height: 16),

            // Selected Color Label
            Center(
              child: Text(
                'Selected: $selectedColorLabel',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4F8C8),
                      foregroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the dialog
void showEditMedicationColorDialog({
  required BuildContext context,
  required int medicationId,
  required String medicationName,
  required String currentColor,
  required Function(int, String) onSave,
}) {
  showDialog(
    context: context,
    builder: (context) => EditMedicationColor(
      medicationId: medicationId,
      medicationName: medicationName,
      currentColor: currentColor,
      onSave: onSave,
    ),
  );
}

// Example usage:
/*
class MedicationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showEditMedicationColorDialog(
              context: context,
              medicationId: 1,
              medicationName: 'Aspirin 100mg',
              currentColor: 'bg-blue-500',
              onSave: (id, color) {
                // Update medication color in your store/database
                print('Updating medication $id to color $color');
              },
            );
          },
          child: Text('Change Color'),
        ),
      ),
    );
  }
}
*/

