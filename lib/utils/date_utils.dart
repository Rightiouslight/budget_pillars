class BudgetPeriod {
  final DateTime start;
  final DateTime end;

  BudgetPeriod({required this.start, required this.end});
}

class DateUtils {
  /// Calculates the start and end dates for a budget period.
  static BudgetPeriod getBudgetPeriod({required int monthStartDate}) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    DateTime startDate = DateTime(year, month, monthStartDate);
    if (now.isBefore(startDate)) {
      // We are in the part of the month that belongs to the *previous* budget period.
      startDate = DateTime(startDate.year, startDate.month - 1, startDate.day);
    }

    DateTime endDate = DateTime(
      startDate.year,
      startDate.month + 1,
      startDate.day,
    );
    // Go to the day before the next period starts.
    endDate = endDate.subtract(const Duration(days: 1));

    // To be fully inclusive, we go to the end of the last day of the budget period.
    return BudgetPeriod(
      start: DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      ), // Time is 00:00:00
      end: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999),
    );
  }

  /// Calculates the specific date for a recurring transaction within a given budget period.
  static DateTime getDueDateForPeriod({
    required int dueDate,
    required int monthStartDate,
  }) {
    final budgetPeriod = getBudgetPeriod(monthStartDate: monthStartDate);
    final year = budgetPeriod.start.year;
    final month = budgetPeriod.start.month;

    int transactionYear = year;
    int transactionMonth = month;

    if (dueDate < monthStartDate) {
      // This due date belongs to the 'next' calendar month relative to the budget period's start.
      // Dart's DateTime constructor handles month overflows automatically (e.g., month 13 becomes January of next year).
      transactionMonth = month + 1;
    }

    return DateTime(transactionYear, transactionMonth, dueDate);
  }

  static DateTime getEffectiveInitialDate({required int day}) {
    final today = DateTime.now();
    final budgetStartDateForCurrentMonth = DateTime(
      today.year,
      today.month,
      day,
    );

    // isAfter or isAtSameMomentAs
    if (!today.isBefore(budgetStartDateForCurrentMonth) && day >= 15) {
      return DateTime(today.year, today.month + 1, day);
    } else {
      return DateTime(today.year, today.month, day);
    }
  }

  /// Checks if the current date is on or after the due date (date-only comparison, ignoring time).
  ///
  /// This is useful for determining if a recurring transaction should be processed.
  ///
  /// Example:
  /// ```dart
  /// final dueDate = DateTime(2025, 11, 15, 10, 30); // Nov 15, 10:30 AM
  /// final today = DateTime(2025, 11, 15, 23, 45);   // Nov 15, 11:45 PM
  /// DateUtils.isDueOrOverdue(dueDate, today); // true (same day)
  ///
  /// final tomorrow = DateTime(2025, 11, 16, 8, 0);
  /// DateUtils.isDueOrOverdue(dueDate, tomorrow); // true (overdue)
  ///
  /// final yesterday = DateTime(2025, 11, 14, 20, 0);
  /// DateUtils.isDueOrOverdue(dueDate, yesterday); // false (not yet due)
  /// ```
  static bool isDueOrOverdue(DateTime dueDate, DateTime currentDate) {
    // Strip time components for date-only comparison
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    return currentDateOnly.isAfter(dueDateOnly) ||
        currentDateOnly.isAtSameMomentAs(dueDateOnly);
  }
}
