import 'package:flutter/material.dart';
import '../functions/get_info.dart';

class DeviceInfoScreen extends StatefulWidget {
  final String deviceId;

  const DeviceInfoScreen({super.key, required this.deviceId});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final info = await getDeviceInfo(widget.deviceId);
      setState(() {
        _info = info;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInfo,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _info == null
          ? const Center(child: Text('No data'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            'Device Information',
            [
              _buildInfoRow(
                'Hardware Version',
                _info!['device_info']['hw_version'],
              ),
              _buildInfoRow(
                'Firmware Version',
                _info!['device_info']['fw_version'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Battery',
            [
              _buildInfoRow(
                'Level',
                '${_info!['battery']['level']}%',
              ),
              _buildInfoRow(
                'Charging',
                _info!['battery']['charging']
                    ? 'Yes'
                    : 'No',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
