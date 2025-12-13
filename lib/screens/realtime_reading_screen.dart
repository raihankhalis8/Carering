import 'package:flutter/material.dart';
import '../functions/get_realtime.dart';
import '../models/real_time_reading.dart';

class RealtimeReadingScreen extends StatefulWidget {
  final String deviceId;

  const RealtimeReadingScreen({super.key, required this.deviceId});

  @override
  State<RealtimeReadingScreen> createState() => _RealtimeReadingScreenState();
}

class _RealtimeReadingScreenState extends State<RealtimeReadingScreen> {
  RealTimeReadingType _selectedType = RealTimeReadingType.heartRate;
  bool _isReading = false;
  List<int>? _readings;
  double? _average;

  Future<void> _startReading() async {
    setState(() {
      _isReading = true;
      _readings = null;
      _average = null;
    });

    try {
      final readings = await getRealTimeReading(widget.deviceId, _selectedType);
      if (readings != null && readings.isNotEmpty) {
        final avg = readings.reduce((a, b) => a + b) / readings.length;
        setState(() {
          _readings = readings;
          _average = avg;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No reading detected. Is the ring being worn?'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isReading = false;
      });
    }
  }

  String _getReadingLabel() {
    switch (_selectedType) {
      case RealTimeReadingType.heartRate:
        return 'Heart Rate';
      case RealTimeReadingType.spo2:
        return 'SpO2';
      case RealTimeReadingType.bloodPressure:
        return 'Blood Pressure';
      case RealTimeReadingType.hrv:
        return 'HRV';
      default:
        return _selectedType.name;
    }
  }

  String _getUnit() {
    switch (_selectedType) {
      case RealTimeReadingType.heartRate:
        return 'bpm';
      case RealTimeReadingType.spo2:
        return '%';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Reading'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<RealTimeReadingType>(
              value: _selectedType,
              isExpanded: true,
              items: RealTimeReadingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _readings = null;
                    _average = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isReading ? null : _startReading,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isReading
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Reading...'),
                ],
              )
                  : Text('Start ${_getReadingLabel()} Reading'),
            ),
            const SizedBox(height: 32),
            if (_average != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _getReadingLabel(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_average!.toStringAsFixed(1)} ${_getUnit()}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average of ${_readings!.length} readings',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Individual Readings:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _readings!
                    .map((r) => Chip(label: Text('$r ${_getUnit()}')))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
