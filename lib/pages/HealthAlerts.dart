import 'package:flutter/material.dart';

// Models
class HealthAlert {
  final int id;
  final String type; // 'critical' or 'warning'
  final String metric;
  final String value;
  final String message;
  final String time;

  HealthAlert({
    required this.id,
    required this.type,
    required this.metric,
    required this.value,
    required this.message,
    required this.time,
  });
}

class HealthAlerts extends StatelessWidget {
  const HealthAlerts({super.key});

  // Mock data
  List<HealthAlert> get alerts => [
    HealthAlert(
      id: 1,
      type: 'warning',
      metric: 'Heart Rate',
      value: '105 BPM',
      message: 'Heart rate elevated above normal range',
      time: '2 min ago',
    ),
    HealthAlert(
      id: 2,
      type: 'critical',
      metric: 'Blood Oxygen',
      value: '91%',
      message: 'Blood oxygen below safe threshold - Emergency contacts notified',
      time: '5 min ago',
    ),
  ];

  IconData _getAlertIcon(String metric) {
    switch (metric) {
      case 'Heart Rate':
        return Icons.favorite;
      case 'Blood Oxygen':
        return Icons.water_drop;
      case 'Sleep':
        return Icons.bedtime;
      default:
        return Icons.show_chart;
    }
  }

  Color _getAlertBorderColor(String type) {
    return type == 'critical'
        ? const Color(0xFFFAA09A)
        : const Color(0xFFF4E87C);
  }

  Color _getAlertBgColor(String type) {
    return type == 'critical'
        ? const Color(0xFFFAA09A).withOpacity(0.2)
        : const Color(0xFFF4E87C).withOpacity(0.2);
  }

  Color _getAlertIconBgColor(String type) {
    return type == 'critical'
        ? const Color(0xFFFAA09A).withOpacity(0.4)
        : const Color(0xFFF4E87C).withOpacity(0.4);
  }

  Color _getAlertIconColor(String type) {
    return type == 'critical'
        ? const Color(0xFFd97066)
        : const Color(0xFFd4b84a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Recent Health Alerts Card
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
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: const Color(0xFFd4b84a),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Recent Health Alerts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Alerts List or Empty State
                      if (alerts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 48,
                                  color: const Color(0xFFB4F8C8),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'All vitals normal',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No alerts in the last 24 hours',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...alerts.map((alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getAlertBgColor(alert.type),
                              border: Border.all(
                                color: _getAlertBorderColor(alert.type),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Alert Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getAlertIconBgColor(alert.type),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getAlertIcon(alert.metric),
                                    color: _getAlertIconColor(alert.type),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Alert Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Metric and Badge
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            alert.metric,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getAlertBorderColor(
                                                  alert.type),
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              alert.type.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Value
                                      Text(
                                        alert.value,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Message
                                      Text(
                                        alert.message,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Time
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            alert.time,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
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
                        )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auto-SOS System Card
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
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: const Color(0xFF5ba3c7),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Auto-SOS System',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'CareRing monitors your vitals 24/7. When critical values are detected, you have 30 seconds to respond before automatic SOS is triggered.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Thresholds
                      _buildThresholdCard(
                        title: 'Heart Rate Thresholds',
                        warning: 'Warning: <60 or >100 BPM',
                        critical: 'Critical: <40 or >120 BPM',
                      ),
                      const SizedBox(height: 8),
                      _buildThresholdCard(
                        title: 'Blood Oxygen Thresholds',
                        warning: 'Warning: <94%',
                        critical: 'Critical: <90%',
                      ),
                      const SizedBox(height: 8),
                      _buildThresholdCard(
                        title: 'Sleep Duration Thresholds',
                        warning: 'Warning: <6 hrs or >9 hrs',
                        critical: 'Critical: <4 hrs or >11 hrs',
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

  Widget _buildThresholdCard({
    required String title,
    required String warning,
    required String critical,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            warning,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            critical,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative version with stateful alerts that can be added/removed
class HealthAlertsWithState extends StatefulWidget {
  const HealthAlertsWithState({super.key});

  @override
  State<HealthAlertsWithState> createState() => _HealthAlertsWithStateState();
}

class _HealthAlertsWithStateState extends State<HealthAlertsWithState> {
  final List<HealthAlert> _alerts = [
    HealthAlert(
      id: 1,
      type: 'warning',
      metric: 'Heart Rate',
      value: '105 BPM',
      message: 'Heart rate elevated above normal range',
      time: '2 min ago',
    ),
    HealthAlert(
      id: 2,
      type: 'critical',
      metric: 'Blood Oxygen',
      value: '91%',
      message: 'Blood oxygen below safe threshold - Emergency contacts notified',
      time: '5 min ago',
    ),
  ];

  void _dismissAlert(int id) {
    setState(() {
      _alerts.removeWhere((alert) => alert.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return HealthAlerts(); // Use the stateless version or customize
  }
}

