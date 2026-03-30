import 'package:url_launcher/url_launcher.dart';

class SmsReminderService {
  static String buildPersonalizedReminderMessage({
    required String customerName,
    required double dueAmount,
    required String storeName,
  }) {
    final amount = dueAmount.abs().toStringAsFixed(2);
    return 'Hi $customerName, gentle reminder from $storeName. Your due amount is Rs $amount. Please clear it when convenient. Thank you!';
  }

  static String buildGenericMassReminderMessage({
    required String storeName,
  }) {
    return 'Hello! This is a payment reminder from $storeName. Please clear your pending due amount at your earliest convenience. Thank you.';
  }

  static Future<bool> sendPersonalizedReminder({
    required String customerName,
    required String phone,
    required double dueAmount,
    required String storeName,
  }) async {
    final message = buildPersonalizedReminderMessage(
      customerName: customerName,
      dueAmount: dueAmount,
      storeName: storeName,
    );

    return _openSmsComposer(
      message: message,
      recipients: [phone.trim()],
    );
  }

  static Future<bool> sendGenericReminderToAll({
    required List<String> phones,
    required String storeName,
  }) async {
    final sanitizedPhones = phones
      .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (sanitizedPhones.isEmpty) {
      return false;
    }

    final message = buildGenericMassReminderMessage(storeName: storeName);
    return _openSmsComposer(message: message, recipients: sanitizedPhones);
  }

  static Future<bool> _openSmsComposer({
    required String message,
    required List<String> recipients,
  }) async {
    try {
      final recipient = recipients.join(',');
      final uri = Uri.parse('sms:$recipient?body=${Uri.encodeComponent(message)}');

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      return false;
    }
  }
}