import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Medications
  static Future<void> saveMedications(List<Map<String, dynamic>> medications) async {
    final json = jsonEncode(medications);
    await _prefs.setString('medications', json);
  }

  static List<Map<String, dynamic>> getMedications() {
    final json = _prefs.getString('medications');
    if (json == null) return [];
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Emergency Contacts
  static Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    final json = jsonEncode(contacts);
    await _prefs.setString('contacts', json);
  }

  static List<Map<String, dynamic>> getContacts() {
    final json = _prefs.getString('contacts');
    if (json == null) return [];
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.cast<Map<String, dynamic>>();
  }

  // SOS History
  static Future<void> saveSOSHistory(List<Map<String, dynamic>> history) async {
    final json = jsonEncode(history);
    await _prefs.setString('sos_history', json);
  }

  static List<Map<String, dynamic>> getSOSHistory() {
    final json = _prefs.getString('sos_history');
    if (json == null) return [];
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Reminder Settings
  static Future<void> saveReminderSettings(Map<String, dynamic> settings) async {
    final json = jsonEncode(settings);
    await _prefs.setString('reminder_settings', json);
  }

  static Map<String, dynamic> getReminderSettings() {
    final json = _prefs.getString('reminder_settings');
    if (json == null) {
      return {
        'ringVibration': true,
        'phoneAlert': true,
        'reminderTime': 15,
      };
    }
    return jsonDecode(json);
  }

  // Device ID
  static Future<void> saveDeviceId(String? deviceId) async {
    if (deviceId == null) {
      await _prefs.remove('device_id');
    } else {
      await _prefs.setString('device_id', deviceId);
    }
  }

  static String? getDeviceId() {
    return _prefs.getString('device_id');
  }

  // Welcome Screen
  static Future<void> setWelcomeShown(bool shown) async {
    await _prefs.setBool('welcome_shown', shown);
  }

  static bool getWelcomeShown() {
    return _prefs.getBool('welcome_shown') ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}