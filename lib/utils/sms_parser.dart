
import 'package:flutter/material.dart';

@immutable
class SmsData {
  final String amount;
  final String date;
  final String description;

  const SmsData({
    required this.amount,
    required this.date,
    required this.description,
  });
}

class SmsParser {
  static SmsData extractSMSData({
    required String message,
    required String currencyString,
    required String startKeywordsString,
    required String stopKeywordsString,
  }) {
    final dateRegex = RegExp(r'(\d{2}-[A-Za-z]{3}-\d{4})|(\d{4}-\d{2}-\d{2})');
    final currencyCode = currencyString.trim().toUpperCase();
    final startKeywords = startKeywordsString.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
    final stopKeywords = stopKeywordsString.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();

    String extractedAmount = 'N/A';
    String extractedDate = 'N/A';
    String extractedDescription = 'N/A';

    // 1. Amount Extraction
    final amountRegex = RegExp('(?:$currencyCode)\\s*([\\d,]+\\.?\\d{0,2})', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(message);
    if (amountMatch != null) {
      final rawAmount = amountMatch.group(1)!;
      final numericAmount = rawAmount.replaceAll(',', '');
      extractedAmount = (double.tryParse(numericAmount) ?? 0).abs().toStringAsFixed(2);
    }

    // 2. Date Extraction
    final dateMatch = dateRegex.firstMatch(message);
    if (dateMatch != null) {
      extractedDate = dateMatch.group(0)!;
    }

    // 3. Description Extraction
    if (startKeywords.isNotEmpty) {
      int bestStartIndex = -1;
      String bestDescription = 'N/A';

      for (final start in startKeywords) {
        final startRegex = RegExp(r'\b' + start + r'\s+', caseSensitive: false);
        final startMatch = startRegex.firstMatch(message);

        if (startMatch != null) {
          final startIndex = startMatch.end;

          if (bestStartIndex == -1 || startIndex < bestStartIndex) {
            int stopIndex = message.length;

            // Find the earliest stop word after the start word
            for (final stop in stopKeywords) {
              final stopRegex = RegExp(r'\s+\b' + stop + r'\b', caseSensitive: false);
              final stopMatch = stopRegex.firstMatch(message.substring(startIndex));
              if (stopMatch != null) {
                final currentStopIndex = startIndex + stopMatch.start;
                if (currentStopIndex < stopIndex) {
                  stopIndex = currentStopIndex;
                }
              }
            }

            // Hard stop boundaries
            final commonStopRegex = RegExp(r'(\s+from acc)|(\s+Available)|(\s+\d{4}-\d{2}-\d{2})|(\s+\d{2}-[A-Za-z]{3}-\d{4})|(\s+\d{2}:\d{2})$', caseSensitive: false);
            final commonStopMatch = commonStopRegex.firstMatch(message.substring(startIndex));
            if (commonStopMatch != null) {
              final commonStopIndex = startIndex + commonStopMatch.start;
              if (commonStopIndex < stopIndex) {
                stopIndex = commonStopIndex;
              }
            }

            final rawDescription = message.substring(startIndex, stopIndex);
            final cleanedDescription = rawDescription.trim();

            if (cleanedDescription.isNotEmpty) {
              bestStartIndex = startIndex;
              bestDescription = cleanedDescription;
            }
          }
        }
      }
      extractedDescription = bestDescription;
    }

    return SmsData(
      amount: extractedAmount,
      date: extractedDate,
      description: extractedDescription,
    );
  }
}
