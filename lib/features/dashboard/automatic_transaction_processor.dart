import 'package:budget_pillars/data/models/account.dart';
import 'package:budget_pillars/data/models/budget_notification.dart';
import 'package:budget_pillars/data/models/card.dart';
import 'package:budget_pillars/data/models/monthly_budget.dart';
import 'package:budget_pillars/data/models/recurring_income.dart';
import 'package:budget_pillars/data/models/transaction.dart';
import 'package:budget_pillars/utils/date_utils.dart' as budget_date_utils;

/// Result of automatic transaction processing
class ProcessingResult {
  final MonthlyBudget updatedBudget;
  final int expensesProcessed;
  final int incomesProcessed;
  final List<String> errors;

  ProcessingResult({
    required this.updatedBudget,
    required this.expensesProcessed,
    required this.incomesProcessed,
    required this.errors,
  });

  bool get hasChanges => expensesProcessed > 0 || incomesProcessed > 0;
  bool get hasErrors => errors.isNotEmpty;
}

/// Handles automatic processing of recurring transactions (expenses and incomes).
///
/// This class is responsible for checking due dates and processing recurring
/// transactions in batch. It runs silently and generates notifications instead
/// of showing toasts.
class AutomaticTransactionProcessor {
  /// Processes all due recurring transactions for the current budget period.
  static ProcessingResult processAutomaticTransactions({
    required MonthlyBudget budget,
    required int monthStartDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final notifications = <BudgetNotification>[];
    final errors = <String>[];
    int expensesProcessed = 0;
    int incomesProcessed = 0;

    // Start with current budget
    var workingBudget = budget;

    // Process recurring expenses
    for (final account in budget.accounts) {
      for (final card in account.cards) {
        // Only process category cards
        if (card is! CategoryCard) continue;

        // Must be recurring with a valid due date
        if (!card.isRecurring || card.dueDate == null || card.dueDate == 99) {
          continue;
        }

        // Check if already processed
        if (budget.autoTransactionsProcessed[card.id] == true) {
          continue;
        }

        // Calculate remaining amount
        final remaining = card.budgetValue - card.currentValue;
        if (remaining <= 0) continue;

        // Check if due
        final dueDate = budget_date_utils.DateUtils.getDueDateForPeriod(
          dueDate: card.dueDate!,
          monthStartDate: monthStartDate,
        );

        if (!budget_date_utils.DateUtils.isDueOrOverdue(dueDate, now)) {
          continue;
        }

        // Process this expense
        try {
          final result = _processRecurringExpense(
            budget: workingBudget,
            account: account,
            category: card,
            amount: remaining,
          );

          workingBudget = result.budget;
          notifications.add(result.notification);
          expensesProcessed++;
        } catch (e) {
          final errorMsg = 'Failed to process ${card.name}: $e';
          errors.add(errorMsg);
          notifications.add(
            BudgetNotification(
              id: 'notif_${DateTime.now().millisecondsSinceEpoch}_error_${card.id}',
              type: NotificationType.error,
              title: 'Automatic Payment Failed',
              message: errorMsg,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // Process recurring incomes
    for (final income in budget.recurringIncomes) {
      // Skip immediate incomes (processed on creation)
      if (income.dayOfMonth == 99) continue;

      // Check if already processed
      if (budget.processedRecurringIncomes[income.id] == true) {
        continue;
      }

      // Check if due
      final dueDate = budget_date_utils.DateUtils.getDueDateForPeriod(
        dueDate: income.dayOfMonth,
        monthStartDate: monthStartDate,
      );

      if (!budget_date_utils.DateUtils.isDueOrOverdue(dueDate, now)) {
        continue;
      }

      // Process this income
      try {
        final result = _processRecurringIncome(
          budget: workingBudget,
          income: income,
        );

        workingBudget = result.budget;
        notifications.add(result.notification);
        incomesProcessed++;
      } catch (e) {
        final errorMsg =
            'Failed to process ${income.description ?? "income"}: $e';
        errors.add(errorMsg);
        notifications.add(
          BudgetNotification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_error_${income.id}',
            type: NotificationType.error,
            title: 'Recurring Income Failed',
            message: errorMsg,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Add all notifications to budget
    if (notifications.isNotEmpty) {
      final allNotifications = [
        ...notifications,
        ...workingBudget.notifications,
      ];
      workingBudget = workingBudget.copyWith(notifications: allNotifications);
    }

    return ProcessingResult(
      updatedBudget: workingBudget,
      expensesProcessed: expensesProcessed,
      incomesProcessed: incomesProcessed,
      errors: errors,
    );
  }

  /// Processes a single recurring expense
  static _ProcessingResult _processRecurringExpense({
    required MonthlyBudget budget,
    required Account account,
    required CategoryCard category,
    required double amount,
  }) {
    // Find default pocket
    final defaultPocket = account.cards.whereType<PocketCard>().firstWhere(
      (p) => p.id == account.defaultPocketId,
    );

    // Check if sinking fund
    if (category.destinationPocketId != null &&
        category.destinationAccountId != null) {
      return _processSinkingFundTransfer(
        budget: budget,
        account: account,
        category: category,
        defaultPocket: defaultPocket,
        amount: amount,
      );
    }

    // Regular expense - update category
    final updatedCards = account.cards.map((card) {
      if (card.id == category.id && card is CategoryCard) {
        return card.copyWith(currentValue: card.currentValue + amount);
      }
      if (card.id == defaultPocket.id && card is PocketCard) {
        return card.copyWith(balance: card.balance - amount);
      }
      return card;
    }).toList();

    // Update account
    final updatedAccounts = budget.accounts.map((acc) {
      return acc.id == account.id ? acc.copyWith(cards: updatedCards) : acc;
    }).toList();

    // Create transaction
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}_auto_${category.id}',
      amount: amount,
      description: 'Auto-payment for ${category.name}',
      date: DateTime.now(),
      accountId: account.id,
      accountName: account.name,
      categoryId: category.id,
      categoryName: category.name,
      sourcePocketId: defaultPocket.id,
    );

    // Update budget
    final updatedBudget = budget.copyWith(
      accounts: updatedAccounts,
      transactions: [transaction, ...budget.transactions],
      autoTransactionsProcessed: {
        ...budget.autoTransactionsProcessed,
        category.id: true,
      },
    );

    // Create notification
    final notification = BudgetNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.automaticPayment,
      title: 'Auto-payment Processed',
      message: '${category.name}: \$${amount.toStringAsFixed(2)}',
      timestamp: DateTime.now(),
      relatedTransactionId: transaction.id,
    );

    return _ProcessingResult(budget: updatedBudget, notification: notification);
  }

  /// Processes a sinking fund transfer
  static _ProcessingResult _processSinkingFundTransfer({
    required MonthlyBudget budget,
    required Account account,
    required CategoryCard category,
    required PocketCard defaultPocket,
    required double amount,
  }) {
    // Find destination
    final destAccount = budget.accounts.firstWhere(
      (a) => a.id == category.destinationAccountId,
    );
    final destPocket = destAccount.cards.whereType<PocketCard>().firstWhere(
      (p) => p.id == category.destinationPocketId,
    );

    // Update source account cards
    final updatedSourceCards = account.cards.map((card) {
      if (card.id == category.id && card is CategoryCard) {
        return card.copyWith(currentValue: card.currentValue + amount);
      }
      if (card.id == defaultPocket.id && card is PocketCard) {
        return card.copyWith(balance: card.balance - amount);
      }
      return card;
    }).toList();

    // Update destination account cards
    final updatedDestCards = destAccount.cards.map((card) {
      if (card.id == destPocket.id && card is PocketCard) {
        return card.copyWith(balance: card.balance + amount);
      }
      return card;
    }).toList();

    // Update accounts
    final updatedAccounts = budget.accounts.map((acc) {
      if (acc.id == account.id) return acc.copyWith(cards: updatedSourceCards);
      if (acc.id == destAccount.id)
        return acc.copyWith(cards: updatedDestCards);
      return acc;
    }).toList();

    // Create transaction
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}_auto_transfer_${category.id}',
      amount: amount,
      description: 'Auto-transfer for ${category.name}',
      date: DateTime.now(),
      accountId: account.id,
      accountName: account.name,
      categoryId: defaultPocket.id,
      categoryName: 'Transfer: ${defaultPocket.name} → ${destPocket.name}',
      sourcePocketId: defaultPocket.id,
      targetAccountId: destAccount.id,
      targetPocketId: destPocket.id,
      targetPocketName: destPocket.name,
    );

    // Update budget
    final updatedBudget = budget.copyWith(
      accounts: updatedAccounts,
      transactions: [transaction, ...budget.transactions],
      autoTransactionsProcessed: {
        ...budget.autoTransactionsProcessed,
        category.id: true,
      },
    );

    // Create notification
    final notification = BudgetNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.automaticPayment,
      title: 'Auto-transfer Processed',
      message:
          '${category.name}: \$${amount.toStringAsFixed(2)} → ${destPocket.name}',
      timestamp: DateTime.now(),
      relatedTransactionId: transaction.id,
    );

    return _ProcessingResult(budget: updatedBudget, notification: notification);
  }

  /// Processes a single recurring income
  static _ProcessingResult _processRecurringIncome({
    required MonthlyBudget budget,
    required RecurringIncome income,
  }) {
    // Find account and pocket
    final account = budget.accounts.firstWhere((a) => a.id == income.accountId);
    final pocket = account.cards.whereType<PocketCard>().firstWhere(
      (p) => p.id == income.pocketId,
    );

    // Update pocket
    final updatedCards = account.cards.map((card) {
      if (card.id == pocket.id && card is PocketCard) {
        return card.copyWith(balance: card.balance + income.amount);
      }
      return card;
    }).toList();

    // Update account
    final updatedAccounts = budget.accounts.map((acc) {
      return acc.id == account.id ? acc.copyWith(cards: updatedCards) : acc;
    }).toList();

    // Create transaction
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}_income_${income.id}',
      amount: income.amount,
      description: income.description ?? 'Recurring Income',
      date: DateTime.now(),
      accountId: account.id,
      accountName: account.name,
      categoryId: pocket.id,
      categoryName: 'Income to ${pocket.name}',
      sourcePocketId: pocket.id,
    );

    // Update budget
    final updatedBudget = budget.copyWith(
      accounts: updatedAccounts,
      transactions: [transaction, ...budget.transactions],
      processedRecurringIncomes: {
        ...budget.processedRecurringIncomes,
        income.id: true,
      },
    );

    // Create notification
    final notification = BudgetNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.recurringIncome,
      title: 'Income Deposited',
      message:
          '${income.description ?? "Income"}: \$${income.amount.toStringAsFixed(2)} → ${pocket.name}',
      timestamp: DateTime.now(),
      relatedTransactionId: transaction.id,
    );

    return _ProcessingResult(budget: updatedBudget, notification: notification);
  }
}

// Private helper class
class _ProcessingResult {
  final MonthlyBudget budget;
  final BudgetNotification notification;

  _ProcessingResult({required this.budget, required this.notification});
}
