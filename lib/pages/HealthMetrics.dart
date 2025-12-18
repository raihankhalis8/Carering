import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HealthMetrics extends StatefulWidget {
  const HealthMetrics({super.key});

  @override
  State<HealthMetrics> createState() => _HealthMetricsState();
}

class _HealthMetricsState extends State<HealthMetrics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF87CEEB),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Charts'),
                Tab(text: 'Health Alerts'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    final appState = Provider.of<AppState>(context);
    final healthData = appState.healthData;

    if (healthData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading health data...'),
          ],
        ),
      );
    }

    // Generate chart data based on current values
    final heartRateData = _generateHeartRateData(healthData.heartRate);
    final stepsData = _generateStepsData(healthData.steps);
    final bloodSugarData = _generateBloodSugarData(healthData.bloodSugar);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Heart Rate Chart
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
                        Icons.favorite,
                        color: const Color(0xFFFAA09A),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Heart Rate Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 10,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final times = ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM'];
                                if (value.toInt() >= 0 && value.toInt() < times.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      times[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 35,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 50,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: heartRateData,
                            isCurved: true,
                            color: const Color(0xFFFAA09A),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAA09A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current: ${healthData.heartRate} BPM',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Normal Range: 60-100 BPM',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
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

          // Steps Chart
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
                        Icons.directions_walk,
                        color: const Color(0xFFB4F8C8),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Steps This Week',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      days[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${(value / 1000).toInt()}k',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 35,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: stepsData,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4F8C8).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today: ${healthData.steps} steps',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${healthData.stepsGoal} steps/day',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        if (healthData.steps < healthData.stepsGoal) ...[
                          const SizedBox(height: 4),
                          Text(
                            '💡 ${healthData.stepsGoal - healthData.steps} more steps to reach goal',
                            style: TextStyle(
                              color: const Color(0xFFd4b84a),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Blood Sugar Chart
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
                        Icons.bloodtype,
                        color: const Color(0xFFC8A8E9),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Blood Sugar Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final times = ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM'];
                                if (value.toInt() >= 0 && value.toInt() < times.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      times[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                              reservedSize: 35,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 70,
                        maxY: 140,
                        lineBarsData: [
                          LineChartBarData(
                            spots: bloodSugarData,
                            isCurved: true,
                            color: const Color(0xFFC8A8E9),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8A8E9).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current: ${healthData.bloodSugar} mg/dL',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Normal Range: 70-100 mg/dL (fasting)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
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

          // Health Insights Card
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF87CEEB).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: const Color(0xFF5ba3c7),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Insights',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInsight(healthData),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight(HealthData data) {
    final insights = <String>[];

    if (data.heartRate >= 60 && data.heartRate <= 100) {
      insights.add('• Heart rate is healthy');
    } else {
      insights.add('• Monitor heart rate closely');
    }

    if (data.steps >= data.stepsGoal) {
      insights.add('• Great job on steps today!');
    } else {
      insights.add('• Try ${data.stepsGoal} steps daily');
    }

    if (data.bloodOxygen >= 95) {
      insights.add('• Blood oxygen excellent');
    } else {
      insights.add('• Blood oxygen needs attention');
    }

    if (data.bloodSugar >= 70 && data.bloodSugar <= 100) {
      insights.add('• Blood sugar in normal range');
    } else {
      insights.add('• Monitor blood sugar levels');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: insights.map((insight) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          insight,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAlertsTab() {
    final appState = Provider.of<AppState>(context);
    final healthAlerts = appState.healthAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                  if (healthAlerts.isEmpty)
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
                    ...healthAlerts.map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: alert.isCritical
                              ? const Color(0xFFFAA09A).withOpacity(0.2)
                              : const Color(0xFFF4E87C).withOpacity(0.2),
                          border: Border.all(
                            color: alert.isCritical
                                ? const Color(0xFFFAA09A)
                                : const Color(0xFFF4E87C),
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
                                color: alert.isCritical
                                    ? const Color(0xFFFAA09A).withOpacity(0.4)
                                    : const Color(0xFFF4E87C).withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getAlertIcon(alert.metric),
                                color: alert.isCritical
                                    ? const Color(0xFFd97066)
                                    : const Color(0xFFd4b84a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Alert Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: alert.isCritical
                                              ? const Color(0xFFFAA09A)
                                              : const Color(0xFFF4E87C),
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          alert.isCritical
                                              ? 'CRITICAL'
                                              : 'WARNING',
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
                                        _formatTimestamp(alert.timestamp),
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
        ],
      ),
    );
  }

  IconData _getAlertIcon(String metric) {
    switch (metric) {
      case 'Heart Rate':
        return Icons.favorite;
      case 'Blood Oxygen':
        return Icons.water_drop;
      case 'Blood Sugar':
        return Icons.bloodtype;
      default:
        return Icons.show_chart;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} day(s) ago';
    }
  }

  // Generate chart data based on current values
  List<FlSpot> _generateHeartRateData(int currentHR) {
    return [
      FlSpot(0, (currentHR - 4).toDouble()),
      FlSpot(1, (currentHR - 2).toDouble()),
      FlSpot(2, (currentHR + 3).toDouble()),
      FlSpot(3, (currentHR - 2).toDouble()),
      FlSpot(4, (currentHR + 2).toDouble()),
      FlSpot(5, currentHR.toDouble()),
    ];
  }

  List<BarChartGroupData> _generateStepsData(int currentSteps) {
    final baseSteps = (currentSteps * 0.7).toInt();
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (baseSteps + 234).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (baseSteps + 721).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: (baseSteps - 144).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: (baseSteps + 1123).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: (baseSteps + 967).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: (baseSteps - 766).toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
      BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: currentSteps.toDouble(), color: const Color(0xFFB4F8C8), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
    ];
  }

  List<FlSpot> _generateBloodSugarData(int currentBS) {
    return [
      FlSpot(0, (currentBS - 7).toDouble()),
      FlSpot(1, (currentBS + 3).toDouble()),
      FlSpot(2, (currentBS + 10).toDouble()),
      FlSpot(3, (currentBS - 5).toDouble()),
      FlSpot(4, (currentBS + 2).toDouble()),
      FlSpot(5, currentBS.toDouble()),
    ];
  }
}