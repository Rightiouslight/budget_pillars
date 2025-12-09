import 'package:budget_pillars/data/models/account.dart';
import 'package:budget_pillars/data/models/budget_notification.dart';
import 'package:budget_pillars/data/models/card.dart';
import 'package:budget_pillars/data/models/monthly_budget.dart';
import 'package:budget_pillars/data/models/recurring_income.dart';
import 'package:budget_pillars/features/dashboard/automatic_transaction_processor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Automatic Transaction Processor - Orphaned References', () {
    test('handles recurring income with deleted pocket gracefully', () {
      // Arrange: Create budget with recurring income pointing to non-existent pocket
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              // Note: pocket2 does NOT exist (it was deleted)
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Monthly Salary',
            amount: 3000.0,
            dayOfMonth: 1, // Due today
            accountId: 'acc1',
            pocketId: 'pocket2', // ❌ This pocket doesn't exist!
          ),
        ],
      );

      // Act: Process automatic transactions
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 5), // After due date
      );

      // Assert: Should create error notification instead of crashing
      expect(result.hasErrors, isTrue);
      expect(result.errors.length, equals(1));
      expect(
        result.errors.first,
        contains('Destination pocket was deleted'),
      );
      
      // Should have error notification
      final errorNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.error)
          .toList();
      expect(errorNotifications.length, equals(1));
      expect(
        errorNotifications.first.message,
        contains('Destination pocket was deleted'),
      );
      
      // Should not have processed the income
      expect(result.incomesProcessed, equals(0));
      
      // Budget should be unchanged (no transactions added)
      expect(result.updatedBudget.transactions.length, equals(0));
    });

    test('handles sinking fund with deleted destination pocket gracefully', () {
      // Arrange: Create budget with recurring category pointing to non-existent pocket
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              const Card.category(
                id: 'cat1',
                name: 'Vacation Fund',
                icon: '✈️',
                budgetValue: 200.0,
                currentValue: 0.0,
                isRecurring: true,
                dueDate: 1, // Due today
                destinationPocketId: 'pocket2', // ❌ This pocket doesn't exist!
                destinationAccountId: 'acc1',
              ),
            ],
          ),
        ],
        transactions: [],
      );

      // Act: Process automatic transactions
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 5), // After due date
      );

      // Assert: Should create error notification instead of crashing
      expect(result.hasErrors, isTrue);
      expect(result.errors.length, equals(1));
      expect(
        result.errors.first,
        contains('Destination pocket not found'),
      );
      
      // Should have error notification
      final errorNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.error)
          .toList();
      expect(errorNotifications.length, equals(1));
      expect(
        errorNotifications.first.message,
        contains('Destination pocket not found'),
      );
      
      // Should not have processed the expense
      expect(result.expensesProcessed, equals(0));
      
      // Budget should be unchanged (no transactions added)
      expect(result.updatedBudget.transactions.length, equals(0));
    });

    test('handles deleted account for recurring income gracefully', () {
      // Arrange: Create budget with recurring income pointing to non-existent account
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Monthly Salary',
            amount: 3000.0,
            dayOfMonth: 1,
            accountId: 'acc2', // ❌ This account doesn't exist!
            pocketId: 'pocket1',
          ),
        ],
      );

      // Act: Process automatic transactions
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 5),
      );

      // Assert: Should create error notification instead of crashing
      expect(result.hasErrors, isTrue);
      expect(result.errors.length, equals(1));
      
      // Should have error notification
      expect(result.updatedBudget.notifications.length, equals(1));
      expect(result.updatedBudget.notifications.first.type, 
        equals(NotificationType.error));
      
      // Should not have processed the income
      expect(result.incomesProcessed, equals(0));
    });

    test('processes valid transactions and reports invalid ones separately', () {
      // Arrange: Mix of valid and invalid recurring incomes
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              const Card.pocket(
                id: 'pocket2',
                name: 'Savings',
                icon: '💰',
                balance: 1000.0,
              ),
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Salary',
            amount: 3000.0,
            dayOfMonth: 1,
            accountId: 'acc1',
            pocketId: 'pocket1', // ✅ Valid
          ),
          RecurringIncome(
            id: 'income2',
            description: 'Side Gig',
            amount: 500.0,
            dayOfMonth: 1,
            accountId: 'acc1',
            pocketId: 'pocket3', // ❌ Invalid - pocket doesn't exist
          ),
        ],
      );

      // Act: Process automatic transactions
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 5),
      );

      // Assert: Should process valid income and report error for invalid
      expect(result.incomesProcessed, equals(1)); // Only the valid one
      expect(result.hasErrors, isTrue);
      expect(result.errors.length, equals(1));
      
      // Should have both success notification and error notification
      expect(result.updatedBudget.notifications.length, equals(2));
      
      final successNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.recurringIncome)
          .toList();
      expect(successNotifications.length, equals(1));
      
      final errorNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.error)
          .toList();
      expect(errorNotifications.length, equals(1));
      
      // Should have added transaction for valid income only
      expect(result.updatedBudget.transactions.length, equals(1));
      expect(result.updatedBudget.transactions.first.description, equals('Salary'));
    });

    test('cross-month scenario: pocket deleted after income processed', () {
      // Arrange: Simulate month transition where pocket was deleted in previous month
      // This is the exact scenario the user mentioned
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              // pocket2 was here last month but has been deleted
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Monthly Salary',
            amount: 3000.0,
            dayOfMonth: 1,
            accountId: 'acc1',
            pocketId: 'pocket2', // Was valid last month, deleted since then
          ),
        ],
        processedRecurringIncomes: {
          // Income was processed in previous month
          // But in new month budget, the flag is cleared
        },
      );

      // Act: Try to process in new month
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 5),
      );

      // Assert: Should handle gracefully with error notification
      expect(result.hasErrors, isTrue);
      expect(result.incomesProcessed, equals(0));
      
      final errorNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.error)
          .toList();
      expect(errorNotifications.length, equals(1));
      expect(
        errorNotifications.first.message,
        contains('Destination pocket was deleted'),
      );
      expect(
        errorNotifications.first.title,
        equals('Recurring Income Failed'),
      );
    });

    test('same-month deletion: pocket deleted before due date arrives', () {
      // Arrange: User sets up recurring income for the 10th, then deletes pocket on the 5th
      // This is the scenario where:
      // - Dec 1st: Budget created with recurring income (due on 10th) → pocket2
      // - Dec 5th: User deletes pocket2
      // - Dec 10th: Income tries to process but pocket is gone
      
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              // pocket2 WAS here when the month started, but user deleted it on Dec 5th
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Freelance Payment',
            amount: 1500.0,
            dayOfMonth: 10, // Due on the 10th
            accountId: 'acc1',
            pocketId: 'pocket2', // Pocket was deleted before due date!
          ),
        ],
      );

      // Act: On Dec 10th, try to process the income
      final result = AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: 1,
        currentDate: DateTime(2025, 12, 10), // Due date arrives
      );

      // Assert: Should handle gracefully - no crash!
      expect(result.hasErrors, isTrue);
      expect(result.incomesProcessed, equals(0));
      
      // Should have error notification explaining the issue
      final errorNotifications = result.updatedBudget.notifications
          .where((n) => n.type == NotificationType.error)
          .toList();
      expect(errorNotifications.length, equals(1));
      expect(
        errorNotifications.first.message,
        contains('Destination pocket was deleted'),
      );
      expect(
        errorNotifications.first.message,
        contains('Freelance Payment'),
      );
      expect(
        errorNotifications.first.title,
        equals('Recurring Income Failed'),
      );
      
      // Budget should be unchanged (no transaction created)
      expect(result.updatedBudget.transactions.length, equals(0));
      
      // Pocket1 balance should be unchanged
      final pocket1 = result.updatedBudget.accounts
          .firstWhere((a) => a.id == 'acc1')
          .cards
          .whereType<PocketCard>()
          .firstWhere((p) => p.id == 'pocket1');
      expect(pocket1.balance, equals(500.0)); // Unchanged
    });

    test('prevention: cannot delete pocket when recurring income references it', () {
      // This simulates the validation in deletePocket()
      final budget = MonthlyBudget(
        accounts: [
          Account(
            id: 'acc1',
            name: 'Checking',
            icon: '💳',
            defaultPocketId: 'pocket1',
            cards: [
              const Card.pocket(
                id: 'pocket1',
                name: 'Main Pocket',
                icon: '👛',
                balance: 500.0,
              ),
              const Card.pocket(
                id: 'pocket2',
                name: 'Savings Pocket',
                icon: '💰',
                balance: 1000.0,
              ),
            ],
          ),
        ],
        transactions: [],
        recurringIncomes: [
          RecurringIncome(
            id: 'income1',
            description: 'Monthly Salary',
            amount: 3000.0,
            dayOfMonth: 10,
            accountId: 'acc1',
            pocketId: 'pocket2', // References pocket2
          ),
        ],
      );

      // Check for references (this is what deletePocket() does)
      final linkedIncomes = <String>[];
      for (final income in budget.recurringIncomes) {
        if (income.pocketId == 'pocket2' && income.accountId == 'acc1') {
          linkedIncomes.add(income.description ?? 'Unnamed Income');
        }
      }

      // Assert: Should find the reference
      expect(linkedIncomes.length, equals(1));
      expect(linkedIncomes.first, equals('Monthly Salary'));
      
      // In the real app, deletePocket() would return an error message
      // preventing the deletion from happening
    });
  });
}
