import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'SOSAlertSystem.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _sosActive = false;
  String _sosTrigger = 'manual';
  String _sosReason = '';

  void _handleManualSOS() {
    setState(() {
      _sosTrigger = 'manual';
      _sosReason = 'Manual emergency activation';
      _sosActive = true;
    });

    // Save to history
    final appState = Provider.of<AppState>(context, listen: false);
    final now = DateTime.now();
    appState.addSOSEvent(SOSEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: 'Today',
      time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      trigger: 'manual',
      reason: 'Manual emergency activation from dashboard',
      status: 'active',
      contactsNotified: appState.contacts.length,
      location: 'Current Location',
    ));

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

    // Update last SOS event to resolved
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.sosHistory.isNotEmpty) {
      final lastEvent = appState.sosHistory.first;
      final updatedEvent = SOSEventModel(
        id: lastEvent.id,
        date: lastEvent.date,
        time: lastEvent.time,
        trigger: lastEvent.trigger,
        reason: lastEvent.reason,
        status: 'resolved',
        contactsNotified: lastEvent.contactsNotified,
        location: lastEvent.location,
      );
      appState.sosHistory[0] = updatedEvent;
      appState.notifyListeners();
    }
  }

  HealthStatus _getHealthStatus(String type, num value) {
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
    } else if (type == 'bloodSugar') {
      final sugar = value as int;
      if (sugar < 70 || sugar > 140) {
        return HealthStatus(
          status: 'critical',
          color: const Color(0xFFd97066),
          bgColor: const Color(0xFFFAA09A).withOpacity(0.4),
        );
      } else if (sugar < 80 || sugar > 125) {
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final healthData = appState.healthData;

    if (healthData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final heartRateStatus = _getHealthStatus('heartRate', healthData.heartRate);
    final bloodOxygenStatus = _getHealthStatus('bloodOxygen', healthData.bloodOxygen);
    final bloodSugarStatus = _getHealthStatus('bloodSugar', healthData.bloodSugar);

    // Get upcoming medications
    final upcomingMeds = appState.medications
        .where((m) => !m.taken)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => appState.refreshData(),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Connection Status Banner
                    if (!healthData.ringConnected)
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
                            Container(
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
                                      color: healthData.ringConnected
                                          ? const Color(0xFFB4F8C8)
                                          : const Color(0xFFF4E87C),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      healthData.ringConnected
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
                                          '${healthData.battery}%',
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
                                value: '${healthData.heartRate} BPM',
                                status: heartRateStatus,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStepsCard(healthData),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildHealthCard(
                                icon: Icons.water_drop,
                                label: 'Blood O₂',
                                value: '${healthData.bloodOxygen}%',
                                status: bloodOxygenStatus,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildHealthCard(
                                icon: Icons.bloodtype,
                                label: 'Blood Sugar',
                                value: '${healthData.bloodSugar} mg/dL',
                                status: bloodSugarStatus,
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
                            if (upcomingMeds.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'No upcoming medications',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...upcomingMeds.map((med) => Container(
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
                                        onPressed: () => appState.toggleMedicationTaken(med.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFB4F8C8),
                                          foregroundColor: Colors.grey[800],
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Mark Taken',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
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
                                label: const Text(
                                  'SOS Emergency',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ),
          ),

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
                  fontSize: 14,
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
                  Icon(Icons.warning, size: 12, color: status.color)
                else if (status.status == 'warning')
                  Icon(Icons.info_outline, size: 12, color: status.color),
                if (status.status != 'normal') const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    status.status == 'critical'
                        ? 'Critical'
                        : status.status == 'warning'
                        ? 'Warning'
                        : 'Normal',
                    style: TextStyle(
                      color: status.color,
                      fontSize: 10,
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

  Widget _buildStepsCard(HealthData healthData) {
    final progress = (healthData.steps / healthData.stepsGoal).clamp(0.0, 1.0);

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
                healthData.steps.toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
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