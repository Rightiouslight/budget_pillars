import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SmsIgnoreService {
  static const String _keyPrefix = 'ignored_sms_';
  static const int _monthsToKeep = 2; // Current + 1 previous

  // Get ignore list for current budget month
  static Future<Set<String>> getIgnoredMessagesForMonth({
    required int year,
    required int month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(year, month);
    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<String>().toSet();
    } catch (e) {
      return {};
    }
  }

  // Add message ID to ignore list for specific month
  static Future<void> addIgnoredMessage({
    required String messageId,
    required int year,
    required int month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(year, month);

    final currentSet = await getIgnoredMessagesForMonth(
      year: year,
      month: month,
    );

    currentSet.add(messageId);

    final jsonString = json.encode(currentSet.toList());
    await prefs.setString(key, jsonString);
  }

  // Check if a message is ignored
  static Future<bool> isMessageIgnored({
    required String messageId,
    required int year,
    required int month,
  }) async {
    final ignoredSet = await getIgnoredMessagesForMonth(
      year: year,
      month: month,
    );
    return ignoredSet.contains(messageId);
  }

  // Clear ignored messages for current month only
  static Future<void> clearCurrentMonth({
    required int year,
    required int month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(year, month);
    await prefs.remove(key);
  }

  // Cleanup old months (keep only recent months)
  static Future<void> cleanupOldMonths({
    required int currentYear,
    required int currentMonth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    // Get cutoff date (keep current + previous months)
    final cutoffDate = DateTime(
      currentYear,
      currentMonth,
      1,
    ).subtract(Duration(days: 30 * (_monthsToKeep - 1)));

    final keysToRemove = <String>[];

    for (final key in allKeys) {
      if (key.startsWith(_keyPrefix)) {
        // Extract year and month from key
        final parts = key.replaceFirst(_keyPrefix, '').split('_');
        if (parts.length == 2) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);

          if (year != null && month != null) {
            final keyDate = DateTime(year, month, 1);

            // If this key is older than cutoff, mark for removal
            if (keyDate.isBefore(cutoffDate)) {
              keysToRemove.add(key);
            }
          }
        }
      }
    }

    // Remove old keys
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  // Get total count of ignored messages across all months (for debugging/stats)
  static Future<int> getTotalIgnoredCount() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    int total = 0;
    for (final key in allKeys) {
      if (key.startsWith(_keyPrefix)) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            final List<dynamic> decoded = json.decode(jsonString);
            total += decoded.length;
          } catch (e) {
            // Skip invalid data
          }
        }
      }
    }
    return total;
  }

  // Helper to generate key
  static String _getKey(int year, int month) {
    return '$_keyPrefix${year}_$month';
  }
}
