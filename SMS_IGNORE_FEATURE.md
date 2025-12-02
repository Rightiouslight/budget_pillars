# SMS Ignore Feature Implementation

## Overview

Allow users to ignore specific SMS messages during import, storing ignored message IDs locally with automatic cleanup to prevent unbounded growth.

## Design Principles

1. **Local Storage Only** - Data stored on device, not synced to cloud
2. **Budget Month Scoped** - Each budget month has its own ignore list
3. **Automatic Cleanup** - Old month data automatically removed
4. **Efficient Storage** - Only store minimal data needed

## Storage Strategy

### Use SharedPreferences for Local Storage

- Fast, simple key-value storage
- Perfect for small lists of IDs
- Survives app restarts
- Not synced to cloud (what we want)

### Data Structure

```dart
// Key format: "ignored_sms_{year}_{month}"
// Example: "ignored_sms_2025_12" for December 2025
// Value: JSON array of message IDs
{
  "ignored_sms_2025_12": ["123", "456", "789"],
  "ignored_sms_2025_11": ["234", "567"],  // Auto-deleted after 2-3 months
  "ignored_sms_2026_01": ["345", "678"]
}
```

### Cleanup Strategy

**Keep only current month + 1 previous month** (configurable)

**Why?**

- Current month: Needed for active imports
- Previous month: Safety buffer for users whose budget crosses month boundaries or imports late
- Anything older: Delete automatically

**Storage Impact:**

- Average SMS ID length: ~10 characters
- 100 ignored messages/month: ~1KB
- 2 months retained: ~2KB total
- Negligible storage impact

## Implementation

### Step 1: Create SMS Ignore Service

Create `lib/services/sms_ignore_service.dart`:

```dart
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
    final cutoffDate = DateTime(currentYear, currentMonth, 1)
        .subtract(Duration(days: 30 * (_monthsToKeep - 1)));

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
```

### Step 2: Update Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.2.2 # Check if already added
```

### Step 3: Update \_SmsTransaction Model

Update `lib/features/dashboard/dialogs/import_from_sms_dialog.dart`:

```dart
class _SmsTransaction {
  final String smsBody;
  final String smsId;  // ADD THIS - unique message ID
  final DateTime date;
  final double amount;
  final String description;
  final bool isDuplicate;
  final bool isSelected;
  final String? categoryId;
  final bool isIgnored;  // ADD THIS - for filtering

  _SmsTransaction({
    required this.smsBody,
    required this.smsId,  // ADD THIS
    required this.date,
    required this.amount,
    required this.description,
    required this.isDuplicate,
    required this.isSelected,
    this.categoryId,
    this.isIgnored = false,  // ADD THIS
  });

  _SmsTransaction copyWith({
    String? smsBody,
    String? smsId,  // ADD THIS
    DateTime? date,
    double? amount,
    String? description,
    bool? isDuplicate,
    bool? isSelected,
    String? categoryId,
    bool? isIgnored,  // ADD THIS
  }) {
    return _SmsTransaction(
      smsBody: smsBody ?? this.smsBody,
      smsId: smsId ?? this.smsId,  // ADD THIS
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      isSelected: isSelected ?? this.isSelected,
      categoryId: categoryId ?? this.categoryId,
      isIgnored: isIgnored ?? this.isIgnored,  // ADD THIS
    );
  }
}
```

### Step 4: Update Import SMS Dialog

Modify `_fetchSmsMessages()` method:

```dart
Future<void> _fetchSmsMessages() async {
  // ... existing code ...

  try {
    // ... existing code to get settings and messages ...

    // Calculate budget period
    final budgetPeriod = app_date_utils.DateUtils.getBudgetPeriod(
      monthStartDate: monthStartDate,
    );

    // Get ignored messages for current budget month
    final budgetYear = budgetPeriod.start.year;
    final budgetMonth = budgetPeriod.start.month;
    final ignoredMessageIds = await SmsIgnoreService.getIgnoredMessagesForMonth(
      year: budgetYear,
      month: budgetMonth,
    );

    // Cleanup old ignored message data (runs in background)
    SmsIgnoreService.cleanupOldMonths(
      currentYear: budgetYear,
      currentMonth: budgetMonth,
    );

    // ... existing message filtering code ...

    for (final message in messagesInPeriod) {
      final messageBody = message.body ?? '';
      final messageId = message.id?.toString() ?? '';  // Get SMS ID

      if (messageBody.isEmpty || messageId.isEmpty) continue;

      // Skip ignored messages
      if (ignoredMessageIds.contains(messageId)) {
        continue;  // Don't even show ignored messages
      }

      // ... existing parsing code ...

      transactions.add(
        _SmsTransaction(
          smsBody: messageBody,
          smsId: messageId,  // ADD THIS
          date: transactionDate,
          amount: -amount,
          description: description,
          isDuplicate: isDuplicate,
          isSelected: !isDuplicate,
          categoryId: null,
          isIgnored: false,
        ),
      );
    }

    // ... rest of existing code ...
  }
}
```

### Step 5: Add Ignore Button to Transaction List Item

In the transaction list item widget (within the import dialog):

```dart
// In the _buildTransactionItem method or similar
Widget _buildTransactionItem(_SmsTransaction transaction, int index) {
  return Card(
    child: ListTile(
      // ... existing content ...
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category picker button
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => _pickCategory(index),
          ),

          // ADD IGNORE BUTTON
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'ignore') {
                await _ignoreMessage(transaction, index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ignore',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20),
                    SizedBox(width: 8),
                    Text('Ignore this message'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<void> _ignoreMessage(_SmsTransaction transaction, int index) async {
  // Get current budget period
  final settingsAsync = ref.read(userSettingsProvider);
  final settings = settingsAsync.value;
  final monthStartDate = settings?.monthStartDate ?? 1;
  final budgetPeriod = app_date_utils.DateUtils.getBudgetPeriod(
    monthStartDate: monthStartDate,
  );

  // Add to ignored list
  await SmsIgnoreService.addIgnoredMessage(
    messageId: transaction.smsId,
    year: budgetPeriod.start.year,
    month: budgetPeriod.start.month,
  );

  // Remove from current list
  setState(() {
    _transactions.removeAt(index);
  });

  // Show confirmation
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message ignored. It will not appear in future imports.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
```

### Step 6: Add Clear Button to Settings

Update `lib/features/settings/settings_screen.dart`:

```dart
// In the SMS Import section, add a button after the phone number field

ListTile(
  leading: const Icon(Icons.delete_sweep),
  title: const Text('Clear Ignored Messages'),
  subtitle: FutureBuilder<int>(
    future: SmsIgnoreService.getTotalIgnoredCount(),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      return Text(
        count > 0
            ? '$count message${count == 1 ? '' : 's'} currently ignored'
            : 'No ignored messages',
      );
    },
  ),
  trailing: IconButton(
    icon: const Icon(Icons.clear),
    onPressed: () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Ignored Messages?'),
          content: const Text(
            'This will clear the list of ignored SMS messages for the current budget month. '
            'These messages will appear in future imports.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Get current budget period
        final settingsAsync = ref.read(userSettingsProvider);
        final settings = settingsAsync.value;
        final monthStartDate = settings?.monthStartDate ?? 1;
        final budgetPeriod = app_date_utils.DateUtils.getBudgetPeriod(
          monthStartDate: monthStartDate,
        );

        await SmsIgnoreService.clearCurrentMonth(
          year: budgetPeriod.start.year,
          month: budgetPeriod.start.month,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ignored messages cleared'),
            ),
          );
        }
      }
    },
  ),
),
```

## Cleanup Efficiency Analysis

### When Cleanup Happens

1. **Every time you fetch SMS messages** - Runs automatically in background
2. **No user action needed** - Completely automatic
3. **Fast operation** - Only checks key names, no heavy processing

### Storage Growth Prevention

**Example Timeline:**

```
January 2025:   Keep Jan, Dec 2024           (2 months)
February 2025:  Keep Feb, Jan                (2 months, auto-delete Dec)
March 2025:     Keep Mar, Feb                (2 months, auto-delete Jan)
```

**Maximum storage:**

- 2 months × 100 messages/month × 10 chars/ID = ~2KB
- Never grows beyond this

### Edge Cases Handled

1. **App not used for months**

   - Next time user imports: Cleanup runs, old data deleted
   - No manual intervention needed

2. **Very heavy users (1000s of messages)**

   - Still only 2 months retained
   - ~20KB max (trivial)

3. **Budget month crosses calendar months**

   - System uses budget period, not calendar month
   - Works correctly with any month start date

4. **Data corruption**
   - Service has try-catch blocks
   - Invalid data silently skipped
   - Won't crash the app

## Testing Checklist

- [ ] Install app and ignore a message
- [ ] Close and reopen app - message still ignored
- [ ] Import again - ignored message doesn't show
- [ ] Clear ignored messages - message appears again
- [ ] Wait for next budget month - old data auto-deleted
- [ ] Verify storage keys in device inspector
- [ ] Test with 0 ignored messages
- [ ] Test with 100+ ignored messages
- [ ] Uninstall/reinstall - data cleared (expected)

## Migration Notes

**No migration needed!**

- New feature, no existing data to migrate
- Service creates data structure on first use
- Backwards compatible

## Future Enhancements (Optional)

1. **Show ignored messages section**

   - Collapsible section showing ignored messages
   - Allow un-ignoring from there

2. **Import ignored messages stats**

   - "Skipped 5 ignored messages" in summary

3. **Bulk ignore by pattern**

   - Ignore all from specific merchant
   - Ignore messages containing certain keywords

4. **Export/Import ignore list**
   - For users switching devices who want to keep list

## Summary

✅ **Efficient Storage:**

- Only 2 months of data kept
- Automatic cleanup
- ~2KB storage max

✅ **Simple UX:**

- One button per message to ignore
- One button in settings to clear
- No complex UI needed

✅ **Local & Fast:**

- SharedPreferences is instant
- No network calls
- No cloud sync needed

✅ **Maintenance-Free:**

- Automatic cleanup
- No manual intervention
- No storage bloat

This solution is elegant, efficient, and solves the problem without adding complexity!
