import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CommunicationService {
  // Make a phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      } else {
        print('Could not launch phone call to $cleanNumber');
        return false;
      }
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  // Open WhatsApp chat
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    cleanNumber = cleanNumber.replaceAll('+', '');

    if (!cleanNumber.startsWith('1') && cleanNumber.length == 10) {
      cleanNumber = '1$cleanNumber';
    }

    final encodedMessage = message != null ? Uri.encodeComponent(message) : '';

    final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$cleanNumber${message != null ? '&text=$encodedMessage' : ''}'
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(whatsappUri);
      } else {
        final Uri webWhatsappUri = Uri.parse(
            'https://wa.me/$cleanNumber${message != null ? '?text=$encodedMessage' : ''}'
        );

        if (await canLaunchUrl(webWhatsappUri)) {
          return await launchUrl(
            webWhatsappUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          print('Could not open WhatsApp');
          return false;
        }
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  // Send SMS
  static Future<bool> sendSMS(String phoneNumber, String message) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanNumber,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      } else {
        print('Could not send SMS to $cleanNumber');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // Share location via WhatsApp
  static Future<bool> shareLocationViaWhatsApp(
      String phoneNumber, {
        double? latitude,
        double? longitude,
      }) async {
    final locationMessage = latitude != null && longitude != null
        ? '📍 Emergency! My location: https://maps.google.com/?q=$latitude,$longitude'
        : '🚨 Emergency! I need help!';

    return await openWhatsApp(phoneNumber, message: locationMessage);
  }

  // Emergency call to all contacts
  static Future<void> emergencyCallAll(
      BuildContext context,
      List<Map<String, String>> contacts,
      ) async {
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contacts available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final selectedContact = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select contact to call:'),
            const SizedBox(height: 16),
            ...contacts.map((contact) => ListTile(
              leading: const Icon(Icons.phone, color: Colors.red),
              title: Text(contact['name'] ?? 'Unknown'),
              subtitle: Text(contact['phone'] ?? ''),
              onTap: () => Navigator.pop(context, contact),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedContact != null && selectedContact['phone'] != null) {
      final success = await makePhoneCall(selectedContact['phone']!);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to make call. Please check permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Notify all contacts via WhatsApp
  static Future<void> notifyAllContactsViaWhatsApp(
      List<Map<String, String>> contacts,
      String emergencyMessage,
      ) async {
    for (final contact in contacts) {
      if (contact['phone'] != null) {
        await openWhatsApp(
          contact['phone']!,
          message: emergencyMessage,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // Check if phone can make calls
  static Future<bool> canMakeCalls() async {
    final Uri testUri = Uri(scheme: 'tel', path: '');
    return await canLaunchUrl(testUri);
  }

  // Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    final Uri testUri = Uri.parse('whatsapp://send');
    return await canLaunchUrl(testUri);
  }
}