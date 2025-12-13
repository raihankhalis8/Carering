import 'package:flutter/material.dart';
import '../functions/get_heart_rate.dart';

class HeartRateScreen extends StatefulWidget {
  final String deviceId;

  const HeartRateScreen({super.key, required this.deviceId});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _readings;
  String? _error;

  Future<void> _loadHeartRate() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _readings = null;
    });

    try {
      final readings = await getHeartRateLog(widget.deviceId, _selectedDate);
      setState(() {
        _readings = readings;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadHeartRate();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHeartRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loadHeartRate,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _readings == null || _readings!.isEmpty
                ? const Center(child: Text('No data for this date'))
                : ListView.builder(
              itemCount: _readings!.length,
              itemBuilder: (context, index) {
                final reading = _readings![index];
                return ListTile(
                  leading: const Icon(Icons.favorite,
                      color: Colors.red),
                  title: Text('${reading['reading']} bpm'),
                  trailing: Text(reading['time_formatted']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
