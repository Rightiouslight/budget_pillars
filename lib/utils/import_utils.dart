import 'package:intl/intl.dart';
import '../data/models/import_profile.dart';

/// Auto-maps CSV columns to transaction fields based on headers and content
ColumnMapping autoMapColumns(List<String> headers, List<List<String>> rows) {
  ColumnMapping mapping = const ColumnMapping();

  if (rows.isEmpty) return mapping;

  final firstRow = rows[0];
  final mappedHeaders = <String>{};

  String? dateColumn;
  String? descriptionColumn;
  String? amountColumn;

  // Helper function to map a field
  void findAndMap(
    String field,
    List<String> keywords,
    bool Function(String) isType,
  ) {
    // Try mapping by header keywords first
    for (final header in headers) {
      if (mappedHeaders.contains(header)) continue;
      final lowerHeader = header.toLowerCase();
      if (keywords.any((kw) => lowerHeader.contains(kw))) {
        if (field == 'date') {
          dateColumn = header;
        } else if (field == 'description') {
          descriptionColumn = header;
        } else if (field == 'amount') {
          amountColumn = header;
        }
        mappedHeaders.add(header);
        return;
      }
    }

    // If not found, try mapping by content type
    for (var i = 0; i < firstRow.length && i < headers.length; i++) {
      final header = headers[i];
      if (mappedHeaders.contains(header)) continue;
      if (isType(firstRow[i])) {
        if (field == 'date') {
          dateColumn = header;
        } else if (field == 'description') {
          descriptionColumn = header;
        } else if (field == 'amount') {
          amountColumn = header;
        }
        mappedHeaders.add(header);
        return;
      }
    }
  }

  final isFloat = (String val) {
    if (val.isEmpty) return false;
    final cleanedVal = val.replaceAll(RegExp(r'[^0-9.-]+'), '');
    final parsed = double.tryParse(cleanedVal);
    return parsed != null && cleanedVal.contains('.');
  };

  final isNumber = (String val) {
    if (val.isEmpty) return false;
    final cleanedVal = val.replaceAll(RegExp(r'[^0-9.-]+'), '');
    return double.tryParse(cleanedVal) != null;
  };

  final isDate = (String val) {
    if (val.isEmpty) return false;
    // Try common date formats
    final formats = [
      'M/d/yyyy',
      'MM/dd/yyyy',
      'd/M/yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd',
      'M/d/yy',
      'MM/dd/yy',
    ];

    for (final format in formats) {
      try {
        final date = DateFormat(format).parseStrict(val);
        return date.year > 1900 && date.year < 2100;
      } catch (_) {
        continue;
      }
    }
    return false;
  };

  final isText = (String val) {
    return val.isNotEmpty && double.tryParse(val) == null;
  };

  // Map date column
  findAndMap('date', ['date'], isDate);

  // Map amount column (prefer float, fallback to number)
  findAndMap('amount', ['amount', 'credit', 'debit'], isFloat);
  if (amountColumn == null) {
    findAndMap('amount', ['amount', 'credit', 'debit'], isNumber);
  }

  // Map description column
  findAndMap('description', [
    'description',
    'memo',
    'details',
    'merchant',
  ], isText);

  return ColumnMapping(
    date: dateColumn,
    description: descriptionColumn,
    amount: amountColumn,
  );
}

/// Extracts transaction data from SMS text
Map<String, String> extractSMSData(
  String smsText,
  String currencyCode,
  String startWords,
  String stopWords,
) {
  String amount = 'N/A';
  String description = 'N/A';
  String date = 'N/A';

  // Extract amount (look for currency symbols and numbers)
  final amountRegex = RegExp(
    r'(?:' +
        currencyCode +
        r'|USD|Rs\.?|INR|EUR|GBP|AUD|\$|₹|€|£)\s*([0-9,]+\.?\d*)',
    caseSensitive: false,
  );

  final amountMatch = amountRegex.firstMatch(smsText);
  if (amountMatch != null) {
    final rawAmount = amountMatch.group(1) ?? '';
    amount = rawAmount.replaceAll(',', '');
  }

  // Extract date (look for common date patterns)
  final datePatterns = [
    RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'), // MM/DD/YYYY or DD-MM-YYYY
    RegExp(r'(\d{4}[-/]\d{1,2}[-/]\d{1,2})'), // YYYY-MM-DD
    RegExp(
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2}(?:,? \d{4})?',
      caseSensitive: false,
    ), // Month DD, YYYY
  ];

  for (final pattern in datePatterns) {
    final match = pattern.firstMatch(smsText);
    if (match != null) {
      date = match.group(0) ?? 'N/A';
      break;
    }
  }

  // Extract description using start and stop words
  if (startWords.isNotEmpty || stopWords.isNotEmpty) {
    final startKeywords = startWords
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final stopKeywords = stopWords
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Add automatic stop keywords
    final autoStopKeywords = [
      'avbl bal',
      'available balance',
      'bal:',
      'balance:',
    ];
    stopKeywords.addAll(autoStopKeywords);

    // Find start position
    int startIndex = -1;

    for (final keyword in startKeywords) {
      final index = smsText.toLowerCase().indexOf(keyword.toLowerCase());
      if (index != -1) {
        startIndex = index + keyword.length;
        break;
      }
    }

    if (startIndex != -1) {
      // Find end position
      int endIndex = smsText.length;

      for (final keyword in stopKeywords) {
        final index = smsText.toLowerCase().indexOf(
          keyword.toLowerCase(),
          startIndex,
        );
        if (index != -1 && index < endIndex) {
          endIndex = index;
        }
      }

      // Also stop at date if found after description start
      if (date != 'N/A') {
        final dateIndex = smsText.indexOf(date, startIndex);
        if (dateIndex != -1 && dateIndex < endIndex) {
          endIndex = dateIndex;
        }
      }

      description = smsText.substring(startIndex, endIndex).trim();

      // Clean up description
      description = description
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'[^\w\s.-]'), '')
          .trim();
    }
  }

  // If no description was extracted but we have amount, try to get merchant name
  if (description == 'N/A' && amount != 'N/A') {
    // Look for words between "at" or "to" and amount
    final merchantRegex = RegExp(
      r'(?:at|to|for)\s+([A-Za-z0-9\s]+?)(?=\s+(?:' +
          currencyCode +
          r'|USD|Rs|INR|\$|₹))',
      caseSensitive: false,
    );
    final merchantMatch = merchantRegex.firstMatch(smsText);
    if (merchantMatch != null) {
      description = merchantMatch.group(1)?.trim() ?? 'N/A';
    }
  }

  return {'amount': amount, 'description': description, 'date': date};
}
