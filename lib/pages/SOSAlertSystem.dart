import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Models
class NotificationStatus {
  final String id;
  final String name;
  final String status; // 'sending', 'sent', 'delivered', 'acknowledged'
  final String time;

  NotificationStatus({
    required this.id,
    required this.name,
    required this.status,
    required this.time,
  });

  NotificationStatus copyWith({
    String? id,
    String? name,
    String? status,
    String? time,
  }) {
    return NotificationStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      time: time ?? this.time,
    );
  }
}

class SOSAlertSystem extends StatefulWidget {
  final bool isActive;
  final VoidCallback onCancel;
  final String trigger; // 'manual' or 'automatic'
  final String? reason;

  const SOSAlertSystem({
    Key? key,
    required this.isActive,
    required this.onCancel,
    required this.trigger,
    this.reason,
  }) : super(key: key);

  @override
  State<SOSAlertSystem> createState() => _SOSAlertSystemState();
}

class _SOSAlertSystemState extends State<SOSAlertSystem> {
  int _countdown = 30;
  bool _isConfirmed = false;
  List<NotificationStatus> _notifications = [];
  bool _phoneAlertActive = false;
  Timer? _countdownTimer;
  final List<Timer> _progressTimers = [];

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeAlert();
    }
  }

  @override
  void didUpdateWidget(SOSAlertSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initializeAlert();
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetAlert();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var timer in _progressTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _initializeAlert() {
    setState(() {
      _countdown = 30;
      _isConfirmed = false;
      _phoneAlertActive = true;
    });

    // Trigger phone vibration
    _triggerPhoneVibration();

    // Initialize emergency contacts
    _notifications = [
      NotificationStatus(
        id: '1',
        name: 'Sarah Johnson (Daughter)',
        status: 'sending',
        time: _getCurrentTime(),
      ),
      NotificationStatus(
        id: '2',
        name: 'Dr. Michael Chen',
        status: 'sending',
        time: _getCurrentTime(),
      ),
      NotificationStatus(
        id: '3',
        name: 'Robert Williams (Son)',
        status: 'sending',
        time: _getCurrentTime(),
      ),
      NotificationStatus(
        id: '4',
        name: 'Emergency Services 911',
        status: 'sending',
        time: _getCurrentTime(),
      ),
    ];

    // Simulate notification progress
    _progressTimers.add(Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          for (int i = 0; i < 2 && i < _notifications.length; i++) {
            _notifications[i] = _notifications[i].copyWith(
              status: 'sent',
              time: _getCurrentTime(),
            );
          }
        });
      }
    }));

    _progressTimers.add(Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _notifications.length; i++) {
            _notifications[i] = _notifications[i].copyWith(
              status: 'sent',
              time: _getCurrentTime(),
            );
          }
        });
      }
    }));

    _progressTimers.add(Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          for (int i = 0; i < 2 && i < _notifications.length; i++) {
            _notifications[i] = _notifications[i].copyWith(
              status: 'delivered',
              time: _getCurrentTime(),
            );
          }
        });
      }
    }));

    _progressTimers.add(Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _notifications.length; i++) {
            _notifications[i] = _notifications[i].copyWith(
              status: 'delivered',
              time: _getCurrentTime(),
            );
          }
        });
      }
    }));

    // Start countdown for automatic trigger
    if (widget.trigger == 'automatic') {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_countdown <= 1) {
              _isConfirmed = true;
              _countdownTimer?.cancel();
              _countdown = 0;
            } else {
              _countdown--;
            }
          });
        }
      });
    }

    // Show SnackBar notification
    if (mounted) {
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
                      '🚨 SOS ALERT ACTIVATED',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Emergency contacts are being notified',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 10),
        ),
      );
    }
  }

  void _resetAlert() {
    _countdownTimer?.cancel();
    for (var timer in _progressTimers) {
      timer.cancel();
    }
    _progressTimers.clear();
    setState(() {
      _countdown = 30;
      _isConfirmed = false;
      _notifications = [];
      _phoneAlertActive = false;
    });
  }

  void _triggerPhoneVibration() {
    // Use HapticFeedback for vibration
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      HapticFeedback.heavyImpact();
    });
  }

  String _getCurrentTime() {
    final now = TimeOfDay.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sending':
        return Colors.grey[400]!;
      case 'sent':
        return const Color(0xFF87CEEB);
      case 'delivered':
        return const Color(0xFFB4F8C8);
      case 'acknowledged':
        return const Color(0xFF6fbb8a);
      default:
        return Colors.grey[400]!;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.access_time;
      case 'sent':
      case 'delivered':
        return Icons.notifications;
      case 'acknowledged':
        return Icons.check_circle;
      default:
        return Icons.access_time;
    }
  }

  String _getStatusText(String status, String time) {
    switch (status) {
      case 'sending':
        return 'Sending...';
      case 'sent':
        return 'Sent at $time';
      case 'delivered':
        return 'Delivered at $time';
      case 'acknowledged':
        return 'Acknowledged at $time';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Alert Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFAA09A).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Color(0xFFd97066),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              '🚨 SOS ALERT ${widget.trigger == 'automatic' ? 'AUTO-TRIGGERED' : 'ACTIVATED'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFd97066),
              ),
            ),
            const SizedBox(height: 8),

            // Description
            if (widget.trigger == 'automatic') ...[
              Text(
                widget.reason ?? 'Critical health values detected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (!_isConfirmed) ...[
                const SizedBox(height: 4),
                Text(
                  'Auto-confirming in $_countdown seconds...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ] else
              Text(
                'Emergency SOS has been activated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 24),

            // Content
            Column(
              children: [
                // Phone Alert Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E87C).withOpacity(0.3),
                    border: Border.all(
                      color: const Color(0xFFF4E87C),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _phoneAlertActive
                              ? const Color(0xFFF4E87C)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.smartphone,
                          color: const Color(0xFFd4b84a),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Alert',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _phoneAlertActive
                                        ? const Color(0xFFF4E87C)
                                        : Colors.grey[500],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _phoneAlertActive ? 'ACTIVE' : 'Inactive',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_phoneAlertActive) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vibrating & Ringing',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Emergency Contact Notifications
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF87CEEB),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifying Emergency Contacts:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._notifications.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(notification.status),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(notification.status),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.name,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getStatusText(
                                        notification.status,
                                        notification.time,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (notification.status == 'delivered')
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF6fbb8a),
                                  size: 20,
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Location Sharing
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4F8C8).withOpacity(0.3),
                    border: Border.all(
                      color: const Color(0xFFB4F8C8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF6fbb8a),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Location Shared',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your current location has been sent to all emergency contacts',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.trigger == 'manual' || _isConfirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFAA09A),
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Close Alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmed = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SOS Confirmed - All contacts notified'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFAA09A),
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: Text(
                        'Confirm Emergency (${_countdown}s)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onCancel();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SOS Cancelled'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8E8E8),
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Cancel - I'm OK",
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

// Example usage in parent widget:
/*
class SOSExample extends StatefulWidget {
  @override
  State<SOSExample> createState() => _SOSExampleState();
}

class _SOSExampleState extends State<SOSExample> {
  bool _sosActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _sosActive = true;
                });
              },
              child: Text('Trigger SOS'),
            ),
          ),
          SOSAlertSystem(
            isActive: _sosActive,
            onCancel: () {
              setState(() {
                _sosActive = false;
              });
            },
            trigger: 'automatic', // or 'manual'
            reason: 'Critical heart rate detected',
          ),
        ],
      ),
    );
  }
}
*/

