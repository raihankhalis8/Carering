import 'package:flutter/material.dart';

// Models
class SOSEvent {
  final int id;
  final String date;
  final String time;
  final String trigger; // 'manual' or 'automatic'
  final String reason;
  final String status; // 'resolved' or 'active'
  final int contactsNotified;
  final String location;

  SOSEvent({
    required this.id,
    required this.date,
    required this.time,
    required this.trigger,
    required this.reason,
    required this.status,
    required this.contactsNotified,
    required this.location,
  });
}

class SOSHistory extends StatelessWidget {
  const SOSHistory({Key? key}) : super(key: key);

  List<SOSEvent> get sosEvents => [
    SOSEvent(
      id: 1,
      date: 'Today',
      time: '3:15 PM',
      trigger: 'manual',
      reason: 'Manual emergency activation from dashboard',
      status: 'resolved',
      contactsNotified: 4,
      location: '123 Main St, Boston MA',
    ),
    SOSEvent(
      id: 2,
      date: 'Today',
      time: '2:34 PM',
      trigger: 'automatic',
      reason: 'Blood oxygen dropped to 89%',
      status: 'resolved',
      contactsNotified: 4,
      location: '123 Main St, Boston MA',
    ),
    SOSEvent(
      id: 3,
      date: 'Yesterday',
      time: '11:23 AM',
      trigger: 'automatic',
      reason: 'Heart rate exceeded 125 BPM',
      status: 'resolved',
      contactsNotified: 4,
      location: 'Home',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // SOS Alert History Card
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
                            'SOS Alert History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Events List or Empty State
                      if (sosEvents.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Text(
                                  'No SOS alerts',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your emergency history will appear here',
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
                        ...sosEvents.map((event) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: event.trigger == 'automatic'
                                      ? const Color(0xFFF4E87C)
                                      .withOpacity(0.4)
                                      : const Color(0xFFFAA09A)
                                      .withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning,
                                  color: event.trigger == 'automatic'
                                      ? const Color(0xFFd4b84a)
                                      : const Color(0xFFd97066),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Event Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // Date/Time and Status
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${event.date} at ${event.time}',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: event.trigger ==
                                                      'automatic'
                                                      ? const Color(
                                                      0xFFF4E87C)
                                                      : const Color(
                                                      0xFFFAA09A),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                                ),
                                                child: Text(
                                                  event.trigger ==
                                                      'automatic'
                                                      ? 'AUTO'
                                                      : 'MANUAL',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: event.status ==
                                                  'resolved'
                                                  ? const Color(0xFFB4F8C8)
                                                  : const Color(0xFFFAA09A),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            event.status,
                                            style: TextStyle(
                                              color: event.status ==
                                                  'resolved'
                                                  ? const Color(0xFF6fbb8a)
                                                  : const Color(0xFFd97066),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Reason
                                    Text(
                                      event.reason,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Details
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${event.contactsNotified} contacts notified',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
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

              // Emergency Response Info Card
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
                      Text(
                        'Emergency Response Info',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        'SOS alerts sent to all contacts via SMS, app notification, and phone call',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        'Your location is shared automatically',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        'Medical information shared with responders',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        '30-second cancel window for auto-triggered alerts',
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

  Widget _buildInfoItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Alternative stateful version for dynamic data
class SOSHistoryWithState extends StatefulWidget {
  const SOSHistoryWithState({Key? key}) : super(key: key);

  @override
  State<SOSHistoryWithState> createState() => _SOSHistoryWithStateState();
}

class _SOSHistoryWithStateState extends State<SOSHistoryWithState> {
  List<SOSEvent> _sosEvents = [
    SOSEvent(
      id: 1,
      date: 'Today',
      time: '3:15 PM',
      trigger: 'manual',
      reason: 'Manual emergency activation from dashboard',
      status: 'resolved',
      contactsNotified: 4,
      location: '123 Main St, Boston MA',
    ),
    SOSEvent(
      id: 2,
      date: 'Today',
      time: '2:34 PM',
      trigger: 'automatic',
      reason: 'Blood oxygen dropped to 89%',
      status: 'resolved',
      contactsNotified: 4,
      location: '123 Main St, Boston MA',
    ),
    SOSEvent(
      id: 3,
      date: 'Yesterday',
      time: '11:23 AM',
      trigger: 'automatic',
      reason: 'Heart rate exceeded 125 BPM',
      status: 'resolved',
      contactsNotified: 4,
      location: 'Home',
    ),
  ];

  void _addSOSEvent(SOSEvent event) {
    setState(() {
      _sosEvents.insert(0, event);
    });
  }

  void _clearHistory() {
    setState(() {
      _sosEvents.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SOSHistory(); // Use the stateless version or customize
  }
}

// Example usage with tab integration:
/*
class EmergencyContactsWithHistory extends StatefulWidget {
  @override
  State<EmergencyContactsWithHistory> createState() =>
      _EmergencyContactsWithHistoryState();
}

class _EmergencyContactsWithHistoryState
    extends State<EmergencyContactsWithHistory>
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
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Contacts'),
              Tab(text: 'SOS History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ContactsTab(),
                SOSHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

