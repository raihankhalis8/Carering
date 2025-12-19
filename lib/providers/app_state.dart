import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../colmi_client.dart';
import '../functions/get_realtime.dart';
import '../functions/get_steps.dart';
import '../functions/get_info.dart';
import '../models/real_time_reading.dart';

class AppState extends ChangeNotifier {
  // Device State
  String? _deviceId;
  bool _isConnected = false;
  HealthData? _healthData;
  Timer? _updateTimer;
  bool _isUpdating = false;
  DateTime? _lastUpdate;

  // Medications
  List<MedicationModel> _medications = [];

  // Emergency Contacts
  List<EmergencyContactModel> _contacts = [];

  // SOS History
  List<SOSEventModel> _sosHistory = [];

  List<HealthAlertModel> _healthAlerts = [];

  // Reminder Settings
  Map<String, dynamic> _reminderSettings = {};

  String? get deviceId => _deviceId;
  bool get isConnected => _isConnected;
  HealthData? get healthData => _healthData;
  bool get isUpdating => _isUpdating;
  DateTime? get lastUpdate => _lastUpdate;
  List<MedicationModel> get medications => _medications;
  List<EmergencyContactModel> get contacts => _contacts;
  List<SOSEventModel> get sosHistory => _sosHistory;
  List<HealthAlertModel> get healthAlerts => _healthAlerts;
  Map<String, dynamic> get reminderSettings => _reminderSettings;

  // Initialize app state
  Future<void> initialize() async {
    await _loadPersistedData();
    await NotificationService.initialize();

    if (_deviceId != null) {
      _isConnected = true;
      _startHealthUpdates();
    }
    notifyListeners();
  }

  Future<void> _loadPersistedData() async {
    _deviceId = StorageService.getDeviceId();

    // Load medications
    final medList = StorageService.getMedications();
    _medications = medList.map((m) => MedicationModel.fromJson(m)).toList();

    // Load contacts
    final contactList = StorageService.getContacts();
    _contacts = contactList.map((c) => EmergencyContactModel.fromJson(c)).toList();

    // Load SOS history
    final sosList = StorageService.getSOSHistory();
    _sosHistory = sosList.map((s) => SOSEventModel.fromJson(s)).toList();

    final alertList = StorageService.getHealthAlerts();
    _healthAlerts = alertList.map((a) => HealthAlertModel.fromJson(a)).toList();

    // Load reminder settings
    _reminderSettings = StorageService.getReminderSettings();
  }

  void setDevice(String deviceId) {
    _deviceId = deviceId;
    _isConnected = true;
    StorageService.saveDeviceId(deviceId);
    _startHealthUpdates();
    notifyListeners();
  }

  void disconnect() {
    _deviceId = null;
    _isConnected = false;
    _updateTimer?.cancel();
    StorageService.saveDeviceId(null);
    notifyListeners();
  }

  void _startHealthUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchHealthData();
    });
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    if (_deviceId == null || _isUpdating) return;

    _isUpdating = true;
    notifyListeners();

    try {
      int heartRate = 100;
      int bloodOxygen = 100;
      int bloodSugar = 100;
      int steps = 100;
      int battery = 100;

      try {
        final hrReadings = await getRealTimeReading(
          _deviceId!,
          RealTimeReadingType.heartRate,
        ).timeout(const Duration(seconds: 60));
        if (hrReadings != null && hrReadings.isNotEmpty) {
          heartRate = (hrReadings.reduce((a, b) => a + b) / hrReadings.length).round();
          print('Heart rate fetch succeed: $heartRate');
        }
      } catch (e) {
        print('Heart rate fetch failed: $e');
      }

      try {
        final spo2Readings = await getRealTimeReading(
          _deviceId!,
          RealTimeReadingType.spo2,
        ).timeout(const Duration(seconds: 60));
        if (spo2Readings != null && spo2Readings.isNotEmpty) {
          bloodOxygen = (spo2Readings.reduce((a, b) => a + b) / spo2Readings.length).round();
          print('SpO2 fetch succeed: $bloodOxygen');
        }
      } catch (e) {
        print('SpO2 fetch failed: $e');
      }

      try {
        final sugarReadings = await getRealTimeReading(
          _deviceId!,
          RealTimeReadingType.bloodSugar,
        ).timeout(const Duration(seconds: 60));
        if (sugarReadings != null && sugarReadings.isNotEmpty) {
          bloodSugar = (sugarReadings.reduce((a, b) => a + b) / sugarReadings.length).round();
          print('Blood sugar fetch succeed: $bloodSugar');
        }
      } catch (e) {
        print('Blood sugar fetch failed: $e');
      }

      try {
        final stepsData = await getSteps(
          _deviceId!,
          DateTime.now(),
        ).timeout(const Duration(seconds: 60));
        if (stepsData != null && stepsData.isNotEmpty) {
          steps = stepsData.fold<int>(0, (sum, item) => sum + (item['steps'] as int));
          print('Steps fetch succeed: $steps');
        }
      } catch (e) {
        print('Steps fetch failed: $e');
      }

      try {
        final deviceInfo = await getDeviceInfo(_deviceId!);
        battery = deviceInfo['battery']['level'] as int;
        print('Battery fetch succeed: $battery');
      } catch (e) {
        print('Battery fetch failed: $e');
      }

      _healthData = HealthData(
        heartRate: heartRate,
        steps: steps,
        stepsGoal: 6000,
        bloodSugar: bloodSugar,
        bloodOxygen: bloodOxygen,
        battery: battery,
        ringConnected: true,
      );

      await _checkHealthAlerts(_healthData!);
      _lastUpdate = DateTime.now();
    } catch (e) {
      print('Error fetching health data: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> _checkHealthAlerts(HealthData data) async {
    final now = DateTime.now();

    if (data.heartRate < 50 || data.heartRate > 120) {
      await _addHealthAlert(
        metric: 'Heart Rate',
        value: '${data.heartRate} BPM',
        message: 'Heart rate is critical (Normal: 60-100 BPM)',
        isCritical: true,
        timestamp: now,
      );

      await NotificationService.showHealthAlert(
        metric: 'Heart Rate',
        value: '${data.heartRate} BPM',
        message: 'Critical level detected',
        isCritical: true,
      );
    } else if (data.heartRate < 60 || data.heartRate > 100) {
      await _addHealthAlert(
        metric: 'Heart Rate',
        value: '${data.heartRate} BPM',
        message: 'Heart rate is elevated',
        isCritical: false,
        timestamp: now,
      );

      await NotificationService.showHealthAlert(
        metric: 'Heart Rate',
        value: '${data.heartRate} BPM',
        message: 'Elevated level detected',
        isCritical: false,
      );
    }

    if (data.bloodOxygen < 90) {
      await _addHealthAlert(
        metric: 'Blood Oxygen',
        value: '${data.bloodOxygen}%',
        message: 'Blood oxygen critically low (Normal: 95-100%)',
        isCritical: true,
        timestamp: now,
      );

      await NotificationService.showHealthAlert(
        metric: 'Blood Oxygen',
        value: '${data.bloodOxygen}%',
        message: 'Critically low level',
        isCritical: true,
      );
    } else if (data.bloodOxygen < 95) {
      await _addHealthAlert(
        metric: 'Blood Oxygen',
        value: '${data.bloodOxygen}%',
        message: 'Blood oxygen is low',
        isCritical: false,
        timestamp: now,
      );

      await NotificationService.showHealthAlert(
        metric: 'Blood Oxygen',
        value: '${data.bloodOxygen}%',
        message: 'Low level detected',
        isCritical: false,
      );
    }

    if (data.bloodSugar < 70 || data.bloodSugar > 140) {
      await _addHealthAlert(
        metric: 'Blood Sugar',
        value: '${data.bloodSugar} mg/dL',
        message: 'Blood sugar is critical (Normal: 70-100 mg/dL)',
        isCritical: true,
        timestamp: now,
      );

      await NotificationService.showHealthAlert(
        metric: 'Blood Sugar',
        value: '${data.bloodSugar} mg/dL',
        message: 'Critical level detected',
        isCritical: true,
      );
    }
  }

  Future<void> _addHealthAlert({
    required String metric,
    required String value,
    required String message,
    required bool isCritical,
    required DateTime timestamp,
  }) async {
    final recentAlerts = _healthAlerts.where((alert) =>
    alert.metric == metric &&
        timestamp.difference(alert.timestamp).inMinutes < 5
    );

    if (recentAlerts.isNotEmpty) return;

    final alert = HealthAlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      metric: metric,
      value: value,
      message: message,
      isCritical: isCritical,
      timestamp: timestamp,
    );

    _healthAlerts.insert(0, alert);
    if (_healthAlerts.length > 50) {
      _healthAlerts = _healthAlerts.sublist(0, 50);
    }

    await _saveHealthAlerts();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _fetchHealthData();
  }

  // Medication Methods
  Future<void> addMedication(MedicationModel medication) async {
    _medications.add(medication);
    await _saveMedications();

    if (_reminderSettings['phoneAlert'] == true) {
      await NotificationService.showMedicationReminder(
        medicationName: medication.name,
        dosage: medication.dosage,
        time: medication.time,
      );
    }

    notifyListeners();
  }

  Future<void> updateMedication(int id, MedicationModel updatedMed) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index] = updatedMed;
      await _saveMedications();
      notifyListeners();
    }
  }

  // 🔧 FIX: Create new list reference for Provider to detect change
  Future<void> toggleMedicationTaken(int id) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      final updatedMed = _medications[index].copyWith(
        taken: !_medications[index].taken,
      );
      // Create new list reference so Provider detects the change
      _medications = List.from(_medications);
      _medications[index] = updatedMed;
      await _saveMedications();

      if (updatedMed.taken) {
        await NotificationService.cancelNotification(id);
      }

      notifyListeners();
    }
  }

  // 🔧 FIX: Create new list instead of modifying in-place
  Future<void> deleteMedication(int id) async {
    // Create new list by filtering, changes reference
    _medications = _medications.where((m) => m.id != id).toList();
    await _saveMedications();
    await NotificationService.cancelNotification(id);
    notifyListeners();
  }

  Future<void> _saveMedications() async {
    final list = _medications.map((m) => m.toJson()).toList();
    await StorageService.saveMedications(list);
  }

  void checkMedicationReminders() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final med in _medications) {
      if (med.taken) continue;

      final times = med.scheduledTime.split('&').map((t) => t.trim()).toList();

      for (final timeStr in times) {
        final scheduledMinutes = _parseTimeToMinutes(timeStr);
        if (scheduledMinutes == -1) continue;

        final minutesOverdue = currentMinutes - scheduledMinutes;

        if (minutesOverdue > 30 && minutesOverdue < 720) {
          if (_reminderSettings['phoneAlert'] == true) {
            NotificationService.showMedicationOverdue(
              medicationName: med.name,
              dosage: med.dosage,
            );
          }
        }
      }
    }
  }

  int _parseTimeToMinutes(String timeStr) {
    final regex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
    final match = regex.firstMatch(timeStr);

    if (match == null) return -1;

    int hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hours != 12) hours += 12;
    if (period == 'AM' && hours == 12) hours = 0;

    return hours * 60 + minutes;
  }

  // Emergency Contact Methods
  Future<void> addContact(EmergencyContactModel contact) async {
    _contacts.add(contact);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> _saveContacts() async {
    final list = _contacts.map((c) => c.toJson()).toList();
    await StorageService.saveContacts(list);
  }

  // SOS Methods
  Future<void> addSOSEvent(SOSEventModel event) async {
    _sosHistory.insert(0, event);
    if (_sosHistory.length > 50) {
      _sosHistory = _sosHistory.sublist(0, 50);
    }
    await _saveSOSHistory();

    await NotificationService.showSOSAlert(
      reason: event.reason,
      contactsCount: event.contactsNotified,
    );

    notifyListeners();
  }

  Future<void> _saveSOSHistory() async {
    final list = _sosHistory.map((s) => s.toJson()).toList();
    await StorageService.saveSOSHistory(list);
  }

  Future<void> _saveHealthAlerts() async {
    final list = _healthAlerts.map((a) => a.toJson()).toList();
    await StorageService.saveHealthAlerts(list);
  }

  // Reminder Settings Methods
  Future<void> updateReminderSettings(Map<String, dynamic> settings) async {
    _reminderSettings = settings;
    await StorageService.saveReminderSettings(settings);
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

// Models
class HealthData {
  final int heartRate;
  final int steps;
  final int stepsGoal;
  final int bloodSugar;
  final int bloodOxygen;
  final int battery;
  final bool ringConnected;

  HealthData({
    required this.heartRate,
    required this.steps,
    required this.stepsGoal,
    required this.bloodSugar,
    required this.bloodOxygen,
    required this.battery,
    required this.ringConnected,
  });
}

class MedicationModel {
  final int id;
  final String name;
  final String dosage;
  final String time;
  final String scheduledTime;
  final String frequency;
  final bool taken;
  final Color color;
  final String notes;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.scheduledTime,
    required this.frequency,
    required this.taken,
    required this.color,
    this.notes = '',
  });

  MedicationModel copyWith({
    int? id,
    String? name,
    String? dosage,
    String? time,
    String? scheduledTime,
    String? frequency,
    bool? taken,
    Color? color,
    String? notes,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      taken: taken ?? this.taken,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'time': time,
    'scheduledTime': scheduledTime,
    'frequency': frequency,
    'taken': taken,
    'colorValue': color.value,
    'notes': notes,
  };

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
    id: json['id'],
    name: json['name'],
    dosage: json['dosage'],
    time: json['time'],
    scheduledTime: json['scheduledTime'],
    frequency: json['frequency'],
    taken: json['taken'],
    color: Color(json['colorValue']),
    notes: json['notes'] ?? '',
  );
}

class EmergencyContactModel {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String initials;
  final Color color;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.initials,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'initials': initials,
    'colorValue': color.value,
  };

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) => EmergencyContactModel(
    id: json['id'],
    name: json['name'],
    relationship: json['relationship'],
    phone: json['phone'],
    initials: json['initials'],
    color: Color(json['colorValue']),
  );
}

class SOSEventModel {
  final String id;
  final String date;
  final String time;
  final String trigger;
  final String reason;
  final String status;
  final int contactsNotified;
  final String location;

  SOSEventModel({
    required this.id,
    required this.date,
    required this.time,
    required this.trigger,
    required this.reason,
    required this.status,
    required this.contactsNotified,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'time': time,
    'trigger': trigger,
    'reason': reason,
    'status': status,
    'contactsNotified': contactsNotified,
    'location': location,
  };

  factory SOSEventModel.fromJson(Map<String, dynamic> json) => SOSEventModel(
    id: json['id'],
    date: json['date'],
    time: json['time'],
    trigger: json['trigger'],
    reason: json['reason'],
    status: json['status'],
    contactsNotified: json['contactsNotified'],
    location: json['location'],
  );
}

class HealthAlertModel {
  final String id;
  final String metric;
  final String value;
  final String message;
  final bool isCritical;
  final DateTime timestamp;

  HealthAlertModel({
    required this.id,
    required this.metric,
    required this.value,
    required this.message,
    required this.isCritical,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'metric': metric,
    'value': value,
    'message': message,
    'isCritical': isCritical,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HealthAlertModel.fromJson(Map<String, dynamic> json) => HealthAlertModel(
    id: json['id'],
    metric: json['metric'],
    value: json['value'],
    message: json['message'],
    isCritical: json['isCritical'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}