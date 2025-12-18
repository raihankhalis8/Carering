import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Request permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Initialize settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    _initialized = true;
  }

  // Medication Reminder Notification
  static Future<void> showMedicationReminder({
    required String medicationName,
    required String dosage,
    required String time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      medicationName.hashCode,
      '💊 Medication Reminder',
      'Time to take $medicationName ($dosage) - Due at $time',
      notificationDetails,
      payload: 'medication:$medicationName',
    );
  }

  // Medication Overdue Notification
  static Future<void> showMedicationOverdue({
    required String medicationName,
    required String dosage,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'medication_overdue',
      'Medication Overdue',
      channelDescription: 'Alerts when medications are overdue',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      (medicationName.hashCode + 1000),
      '⚠️ Medication Overdue!',
      '$medicationName ($dosage) is overdue. Please take it now.',
      notificationDetails,
      payload: 'overdue:$medicationName',
    );
  }

  // SOS Emergency Notification
  static Future<void> showSOSAlert({
    required String reason,
    required int contactsCount,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'sos_alerts',
      'SOS Emergency Alerts',
      channelDescription: 'Critical emergency alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFd97066),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000, 500, 1000]),
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      '🚨 SOS EMERGENCY ACTIVATED',
      '$reason - Notifying $contactsCount emergency contacts',
      notificationDetails,
      payload: 'sos:emergency',
    );
  }

  // Health Alert Notification
  static Future<void> showHealthAlert({
    required String metric,
    required String value,
    required String message,
    required bool isCritical,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      isCritical ? 'health_critical' : 'health_warning',
      isCritical ? 'Critical Health Alerts' : 'Health Warnings',
      channelDescription: 'Alerts about your health metrics',
      importance: isCritical ? Importance.max : Importance.high,
      priority: isCritical ? Priority.max : Priority.high,
      icon: '@mipmap/ic_launcher',
      color: isCritical ? const Color(0xFFd97066) : const Color(0xFFd4b84a),
      playSound: true,
      enableVibration: true,
      vibrationPattern: isCritical
          ? Int64List.fromList([0, 1000, 500, 1000])
          : Int64List.fromList([0, 500, 200, 500]),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: isCritical
          ? InterruptionLevel.critical
          : InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      metric.hashCode,
      isCritical ? '⚠️ Critical Health Alert' : '💡 Health Warning',
      '$metric: $value - $message',
      notificationDetails,
      payload: 'health:$metric',
    );
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}