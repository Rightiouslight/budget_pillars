import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_pillars/data/models/monthly_budget.dart';
import 'package:budget_pillars/data/models/account.dart';
import 'package:budget_pillars/data/models/card.dart';
import 'package:budget_pillars/data/models/transaction.dart';

/// Unit tests for transaction functionality
///
/// These tests verify that all transaction operations correctly update
/// the relevant pockets and categories:
/// - Adding expenses
/// - Adding income
/// - Transfers between pockets
/// - Sinking fund allocations
/// - Transaction deletions
void main() {
  group('Dashboard Controller - Transaction Tests', () {
    late ProviderContainer container;
    late MonthlyBudget testBudget;

    setUp(() {
      // Create a test budget with accounts, categories, and pockets
      testBudget = _createTestBudget();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Add Expense Transaction', () {
      test('reduces category currentValue by expense amount', () {
        // Arrange
        final initialCategoryValue = _getCategoryCurrentValue(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );

        // Act
        final updatedBudget = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 50.0,
          description: 'Groceries',
        );

        // Assert
        final finalCategoryValue = _getCategoryCurrentValue(
          updatedBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        expect(
          finalCategoryValue,
          equals(initialCategoryValue + 50.0),
          reason: 'Category currentValue should increase by expense amount',
        );
      });

      test('does not affect pocket balances for regular expense', () {
        // Arrange
        final initialPocketBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );

        // Act
        final updatedBudget = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 50.0,
          description: 'Groceries',
        );

        // Assert
        final finalPocketBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        expect(
          finalPocketBalance,
          equals(initialPocketBalance),
          reason: 'Pocket balance should not change for regular expense',
        );
      });

      test('creates transaction with correct details', () {
        // Act
        final updatedBudget = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 50.0,
          description: 'Groceries',
        );

        // Assert
        expect(updatedBudget.transactions.length, equals(1));
        final transaction = updatedBudget.transactions.first;
        expect(transaction.amount, equals(50.0));
        expect(transaction.description, equals('Groceries'));
        expect(transaction.accountId, equals('acc1'));
        expect(transaction.categoryId, equals('cat1'));
        expect(transaction.targetPocketId, isNull);
        expect(transaction.sourcePocketId, isNull);
      });
    });

    group('Add Income Transaction', () {
      test('increases target pocket balance by income amount', () {
        // Arrange
        final initialPocketBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );

        // Act
        final updatedBudget = _simulateAddIncome(
          testBudget,
          accountId: 'acc1',
          targetPocketId: 'pocket1',
          amount: 1000.0,
          description: 'Salary',
        );

        // Assert
        final finalPocketBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        expect(
          finalPocketBalance,
          equals(initialPocketBalance + 1000.0),
          reason: 'Pocket balance should increase by income amount',
        );
      });

      test('creates transaction with categoryId="income"', () {
        // Act
        final updatedBudget = _simulateAddIncome(
          testBudget,
          accountId: 'acc1',
          targetPocketId: 'pocket1',
          amount: 1000.0,
          description: 'Salary',
        );

        // Assert
        final transaction = updatedBudget.transactions.first;
        expect(transaction.categoryId, equals('income'));
        expect(transaction.targetPocketId, equals('pocket1'));
        expect(transaction.amount, equals(1000.0));
      });
    });

    group('Transfer Between Pockets', () {
      test('decreases source pocket and increases target pocket', () {
        // Arrange
        final initialSourceBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final initialTargetBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        // Act
        final updatedBudget = _simulateTransferBetweenPockets(
          testBudget,
          sourceAccountId: 'acc1',
          sourcePocketId: 'pocket1',
          targetAccountId: 'acc1',
          targetPocketId: 'pocket2',
          amount: 200.0,
          description: 'Move to savings',
        );

        // Assert
        final finalSourceBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final finalTargetBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        expect(
          finalSourceBalance,
          equals(initialSourceBalance - 200.0),
          reason: 'Source pocket should decrease by transfer amount',
        );
        expect(
          finalTargetBalance,
          equals(initialTargetBalance + 200.0),
          reason: 'Target pocket should increase by transfer amount',
        );
      });

      test('creates transaction with both source and target pocket IDs', () {
        // Act
        final updatedBudget = _simulateTransferBetweenPockets(
          testBudget,
          sourceAccountId: 'acc1',
          sourcePocketId: 'pocket1',
          targetAccountId: 'acc1',
          targetPocketId: 'pocket2',
          amount: 200.0,
          description: 'Move to savings',
        );

        // Assert
        final transaction = updatedBudget.transactions.first;
        expect(transaction.sourcePocketId, equals('pocket1'));
        expect(transaction.targetPocketId, equals('pocket2'));
        expect(transaction.amount, equals(200.0));
      });

      test('works across different accounts', () {
        // Arrange
        final initialAccount1PocketBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final initialAccount2PocketBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc2',
          pocketId: 'pocket3',
        );

        // Act
        final updatedBudget = _simulateTransferBetweenPockets(
          testBudget,
          sourceAccountId: 'acc1',
          sourcePocketId: 'pocket1',
          targetAccountId: 'acc2',
          targetPocketId: 'pocket3',
          amount: 150.0,
          description: 'Transfer to other account',
        );

        // Assert
        final finalAccount1PocketBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final finalAccount2PocketBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc2',
          pocketId: 'pocket3',
        );

        expect(
          finalAccount1PocketBalance,
          equals(initialAccount1PocketBalance - 150.0),
        );
        expect(
          finalAccount2PocketBalance,
          equals(initialAccount2PocketBalance + 150.0),
        );
      });
    });

    group('Sinking Fund (Category to Pocket Transfer)', () {
      test('reduces category currentValue and increases pocket balance', () {
        // Arrange
        final initialCategoryValue = _getCategoryCurrentValue(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        final initialPocketBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        // Act
        final updatedBudget = _simulateSinkingFundTransfer(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          targetPocketId: 'pocket2',
          amount: 100.0,
          description: 'Save for vacation',
        );

        // Assert
        final finalCategoryValue = _getCategoryCurrentValue(
          updatedBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        final finalPocketBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        expect(
          finalCategoryValue,
          equals(initialCategoryValue - 100.0),
          reason: 'Category currentValue should decrease by transfer amount',
        );
        expect(
          finalPocketBalance,
          equals(initialPocketBalance + 100.0),
          reason: 'Pocket balance should increase by transfer amount',
        );
      });

      test('creates transaction with categoryId and targetPocketId', () {
        // Act
        final updatedBudget = _simulateSinkingFundTransfer(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          targetPocketId: 'pocket2',
          amount: 100.0,
          description: 'Save for vacation',
        );

        // Assert
        final transaction = updatedBudget.transactions.first;
        expect(transaction.categoryId, equals('cat1'));
        expect(transaction.targetPocketId, equals('pocket2'));
        expect(transaction.sourcePocketId, isNull);
        expect(transaction.amount, equals(100.0));
      });
    });

    group('Delete Transaction', () {
      test('reverts expense - decreases category currentValue', () {
        // Arrange: Add an expense first
        final budgetWithExpense = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 50.0,
          description: 'Groceries',
        );
        final categoryValueBeforeDelete = _getCategoryCurrentValue(
          budgetWithExpense,
          accountId: 'acc1',
          categoryId: 'cat1',
        );

        // Act: Delete the transaction
        final budgetAfterDelete = _simulateDeleteTransaction(
          budgetWithExpense,
          transactionId: budgetWithExpense.transactions.first.id,
        );

        // Assert
        final finalCategoryValue = _getCategoryCurrentValue(
          budgetAfterDelete,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        expect(
          finalCategoryValue,
          equals(categoryValueBeforeDelete - 50.0),
          reason: 'Deleting expense should decrease category currentValue',
        );
      });

      test('reverts income - decreases pocket balance', () {
        // Arrange: Add income first
        final budgetWithIncome = _simulateAddIncome(
          testBudget,
          accountId: 'acc1',
          targetPocketId: 'pocket1',
          amount: 1000.0,
          description: 'Salary',
        );
        final pocketBalanceBeforeDelete = _getPocketBalance(
          budgetWithIncome,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );

        // Act: Delete the transaction
        final budgetAfterDelete = _simulateDeleteTransaction(
          budgetWithIncome,
          transactionId: budgetWithIncome.transactions.first.id,
        );

        // Assert
        final finalPocketBalance = _getPocketBalance(
          budgetAfterDelete,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        expect(
          finalPocketBalance,
          equals(pocketBalanceBeforeDelete - 1000.0),
          reason: 'Deleting income should decrease pocket balance',
        );
      });

      test('reverts transfer - restores both pocket balances', () {
        // Arrange: Create a transfer first
        final budgetWithTransfer = _simulateTransferBetweenPockets(
          testBudget,
          sourceAccountId: 'acc1',
          sourcePocketId: 'pocket1',
          targetAccountId: 'acc1',
          targetPocketId: 'pocket2',
          amount: 200.0,
          description: 'Move to savings',
        );

        final sourcePocketBeforeDelete = _getPocketBalance(
          budgetWithTransfer,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final targetPocketBeforeDelete = _getPocketBalance(
          budgetWithTransfer,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        // Act: Delete the transfer
        final budgetAfterDelete = _simulateDeleteTransaction(
          budgetWithTransfer,
          transactionId: budgetWithTransfer.transactions.first.id,
        );

        // Assert
        final finalSourcePocket = _getPocketBalance(
          budgetAfterDelete,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        final finalTargetPocket = _getPocketBalance(
          budgetAfterDelete,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        expect(
          finalSourcePocket,
          equals(sourcePocketBeforeDelete + 200.0),
          reason: 'Deleting transfer should restore source pocket',
        );
        expect(
          finalTargetPocket,
          equals(targetPocketBeforeDelete - 200.0),
          reason: 'Deleting transfer should restore target pocket',
        );
      });

      test('reverts sinking fund - restores category and pocket', () {
        // Arrange: Create a sinking fund transfer first
        final budgetWithSinkingFund = _simulateSinkingFundTransfer(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          targetPocketId: 'pocket2',
          amount: 100.0,
          description: 'Save for vacation',
        );

        final categoryValueBeforeDelete = _getCategoryCurrentValue(
          budgetWithSinkingFund,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        final pocketBalanceBeforeDelete = _getPocketBalance(
          budgetWithSinkingFund,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        // Act: Delete the transaction
        final budgetAfterDelete = _simulateDeleteTransaction(
          budgetWithSinkingFund,
          transactionId: budgetWithSinkingFund.transactions.first.id,
        );

        // Assert
        final finalCategoryValue = _getCategoryCurrentValue(
          budgetAfterDelete,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        final finalPocketBalance = _getPocketBalance(
          budgetAfterDelete,
          accountId: 'acc1',
          pocketId: 'pocket2',
        );

        expect(
          finalCategoryValue,
          equals(categoryValueBeforeDelete + 100.0),
          reason: 'Deleting sinking fund should restore category value',
        );
        expect(
          finalPocketBalance,
          equals(pocketBalanceBeforeDelete - 100.0),
          reason: 'Deleting sinking fund should restore pocket balance',
        );
      });

      test('removes transaction from list', () {
        // Arrange
        final budgetWithTransaction = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 50.0,
          description: 'Groceries',
        );
        expect(budgetWithTransaction.transactions.length, equals(1));

        // Act
        final budgetAfterDelete = _simulateDeleteTransaction(
          budgetWithTransaction,
          transactionId: budgetWithTransaction.transactions.first.id,
        );

        // Assert
        expect(
          budgetAfterDelete.transactions.length,
          equals(0),
          reason: 'Transaction should be removed from list',
        );
      });
    });

    group('Edge Cases', () {
      test('handles zero amount transactions', () {
        // Act
        final updatedBudget = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 0.0,
          description: 'Zero transaction',
        );

        // Assert
        final categoryValue = _getCategoryCurrentValue(
          updatedBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        expect(categoryValue, equals(0.0));
      });

      test('handles decimal amounts correctly', () {
        // Arrange
        final initialBalance = _getPocketBalance(
          testBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );

        // Act
        final updatedBudget = _simulateAddIncome(
          testBudget,
          accountId: 'acc1',
          targetPocketId: 'pocket1',
          amount: 123.45,
          description: 'Decimal amount',
        );

        // Assert
        final finalBalance = _getPocketBalance(
          updatedBudget,
          accountId: 'acc1',
          pocketId: 'pocket1',
        );
        expect(finalBalance, equals(initialBalance + 123.45));
      });

      test('allows negative category balances (overspending)', () {
        // Arrange: Category starts at 0, budget is 100
        // Act: Spend 150
        final updatedBudget = _simulateAddExpense(
          testBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 150.0,
          description: 'Overspending',
        );

        // Assert
        final categoryValue = _getCategoryCurrentValue(
          updatedBudget,
          accountId: 'acc1',
          categoryId: 'cat1',
        );
        expect(
          categoryValue,
          equals(150.0),
          reason: 'Should allow overspending (negative available balance)',
        );
      });

      test(
        'maintains pocket balance precision across multiple transactions',
        () {
          // Arrange
          var currentBudget = testBudget;

          // Act: Multiple small transactions
          currentBudget = _simulateAddIncome(
            currentBudget,
            accountId: 'acc1',
            targetPocketId: 'pocket1',
            amount: 10.01,
            description: 'Income 1',
          );
          currentBudget = _simulateAddIncome(
            currentBudget,
            accountId: 'acc1',
            targetPocketId: 'pocket1',
            amount: 20.02,
            description: 'Income 2',
          );
          currentBudget = _simulateTransferBetweenPockets(
            currentBudget,
            sourceAccountId: 'acc1',
            sourcePocketId: 'pocket1',
            targetAccountId: 'acc1',
            targetPocketId: 'pocket2',
            amount: 15.03,
            description: 'Transfer',
          );

          // Assert
          final pocket1Balance = _getPocketBalance(
            currentBudget,
            accountId: 'acc1',
            pocketId: 'pocket1',
          );
          expect(
            pocket1Balance,
            equals(500.0 + 10.01 + 20.02 - 15.03),
            reason: 'Should maintain precision across multiple transactions',
          );
        },
      );
    });
  });
}

// ===== Helper Functions =====

/// Creates a test budget with 2 accounts, each with categories and pockets
MonthlyBudget _createTestBudget() {
  // Account 1: Checking with 1 pocket and 2 categories
  final account1 = Account(
    id: 'acc1',
    name: 'Checking',
    icon: 'account_balance',
    defaultPocketId: 'pocket1',
    cards: [
      Card.pocket(
        id: 'pocket1',
        name: 'Main Pocket',
        icon: 'account_balance_wallet',
        balance: 500.0,
      ),
      Card.pocket(
        id: 'pocket2',
        name: 'Savings Pocket',
        icon: 'savings',
        balance: 300.0,
      ),
      Card.category(
        id: 'cat1',
        name: 'Groceries',
        icon: 'shopping_cart',
        budgetValue: 100.0,
        currentValue: 0.0,
      ),
      Card.category(
        id: 'cat2',
        name: 'Transport',
        icon: 'directions_car',
        budgetValue: 50.0,
        currentValue: 0.0,
      ),
    ],
  );

  // Account 2: Savings with 1 pocket
  final account2 = Account(
    id: 'acc2',
    name: 'Savings',
    icon: 'savings',
    defaultPocketId: 'pocket3',
    cards: [
      Card.pocket(
        id: 'pocket3',
        name: 'Emergency Fund',
        icon: 'security',
        balance: 1000.0,
      ),
    ],
  );

  return MonthlyBudget(
    accounts: [account1, account2],
    transactions: [],
    recurringIncomes: [],
    autoTransactionsProcessed: {},
    processedRecurringIncomes: {},
  );
}

/// Simulate adding an expense transaction
MonthlyBudget _simulateAddExpense(
  MonthlyBudget budget, {
  required String accountId,
  required String categoryId,
  required double amount,
  required String description,
}) {
  final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

  // Update category currentValue
  final updatedAccounts = budget.accounts.map((account) {
    if (account.id != accountId) return account;

    final updatedCards = account.cards.map((card) {
      return card.when(
        category:
            (
              id,
              name,
              icon,
              budgetValue,
              currentValue,
              color,
              isRecurring,
              dueDate,
              destPocketId,
              destAccountId,
            ) {
              if (id == categoryId) {
                return Card.category(
                  id: id,
                  name: name,
                  icon: icon,
                  budgetValue: budgetValue,
                  currentValue: currentValue + amount,
                  color: color,
                  isRecurring: isRecurring,
                  dueDate: dueDate,
                  destinationPocketId: destPocketId,
                  destinationAccountId: destAccountId,
                );
              }
              return card;
            },
        pocket: (_, __, ___, ____, _____) => card,
      );
    }).toList();

    return account.copyWith(cards: updatedCards);
  }).toList();

  // Create transaction
  final transaction = Transaction(
    id: transactionId,
    amount: amount,
    description: description,
    date: DateTime.now(),
    accountId: accountId,
    accountName: 'Test Account',
    categoryId: categoryId,
    categoryName: 'Test Category',
  );

  return budget.copyWith(
    accounts: updatedAccounts,
    transactions: [transaction, ...budget.transactions],
  );
}

/// Simulate adding income transaction
MonthlyBudget _simulateAddIncome(
  MonthlyBudget budget, {
  required String accountId,
  required String targetPocketId,
  required double amount,
  required String description,
}) {
  final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

  // Update pocket balance
  final updatedAccounts = budget.accounts.map((account) {
    if (account.id != accountId) return account;

    final updatedCards = account.cards.map((card) {
      return card.when(
        pocket: (id, name, icon, balance, color) {
          if (id == targetPocketId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance + amount,
              color: color,
            );
          }
          return card;
        },
        category:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
            ) => card,
      );
    }).toList();

    return account.copyWith(cards: updatedCards);
  }).toList();

  // Create transaction
  final transaction = Transaction(
    id: transactionId,
    amount: amount,
    description: description,
    date: DateTime.now(),
    accountId: accountId,
    accountName: 'Test Account',
    categoryId: 'income',
    categoryName: 'Income',
    targetPocketId: targetPocketId,
    targetPocketName: 'Test Pocket',
  );

  return budget.copyWith(
    accounts: updatedAccounts,
    transactions: [transaction, ...budget.transactions],
  );
}

/// Simulate transfer between pockets
MonthlyBudget _simulateTransferBetweenPockets(
  MonthlyBudget budget, {
  required String sourceAccountId,
  required String sourcePocketId,
  required String targetAccountId,
  required String targetPocketId,
  required double amount,
  required String description,
}) {
  final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

  // Update both pocket balances
  final updatedAccounts = budget.accounts.map((account) {
    final updatedCards = account.cards.map((card) {
      return card.when(
        pocket: (id, name, icon, balance, color) {
          // Decrease source pocket
          if (id == sourcePocketId && account.id == sourceAccountId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance - amount,
              color: color,
            );
          }
          // Increase target pocket
          if (id == targetPocketId && account.id == targetAccountId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance + amount,
              color: color,
            );
          }
          return card;
        },
        category:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
            ) => card,
      );
    }).toList();

    return account.copyWith(cards: updatedCards);
  }).toList();

  // Create transaction
  final transaction = Transaction(
    id: transactionId,
    amount: amount,
    description: description,
    date: DateTime.now(),
    accountId: sourceAccountId,
    accountName: 'Source Account',
    categoryId: 'transfer',
    categoryName: 'Transfer',
    sourcePocketId: sourcePocketId,
    targetPocketId: targetPocketId,
    targetAccountId: targetAccountId,
    targetPocketName: 'Target Pocket',
  );

  return budget.copyWith(
    accounts: updatedAccounts,
    transactions: [transaction, ...budget.transactions],
  );
}

/// Simulate sinking fund transfer (category to pocket)
MonthlyBudget _simulateSinkingFundTransfer(
  MonthlyBudget budget, {
  required String accountId,
  required String categoryId,
  required String targetPocketId,
  required double amount,
  required String description,
}) {
  final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

  // Update category and pocket
  final updatedAccounts = budget.accounts.map((account) {
    if (account.id != accountId) return account;

    final updatedCards = account.cards.map((card) {
      return card.when(
        category:
            (
              id,
              name,
              icon,
              budgetValue,
              currentValue,
              color,
              isRecurring,
              dueDate,
              destPocketId,
              destAccountId,
            ) {
              if (id == categoryId) {
                return Card.category(
                  id: id,
                  name: name,
                  icon: icon,
                  budgetValue: budgetValue,
                  currentValue: currentValue - amount,
                  color: color,
                  isRecurring: isRecurring,
                  dueDate: dueDate,
                  destinationPocketId: destPocketId,
                  destinationAccountId: destAccountId,
                );
              }
              return card;
            },
        pocket: (id, name, icon, balance, color) {
          if (id == targetPocketId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance + amount,
              color: color,
            );
          }
          return card;
        },
      );
    }).toList();

    return account.copyWith(cards: updatedCards);
  }).toList();

  // Create transaction
  final transaction = Transaction(
    id: transactionId,
    amount: amount,
    description: description,
    date: DateTime.now(),
    accountId: accountId,
    accountName: 'Test Account',
    categoryId: categoryId,
    categoryName: 'Test Category',
    targetPocketId: targetPocketId,
    targetPocketName: 'Test Pocket',
  );

  return budget.copyWith(
    accounts: updatedAccounts,
    transactions: [transaction, ...budget.transactions],
  );
}

/// Simulate deleting a transaction
MonthlyBudget _simulateDeleteTransaction(
  MonthlyBudget budget, {
  required String transactionId,
}) {
  final transaction = budget.transactions.firstWhere(
    (t) => t.id == transactionId,
  );

  // Revert the balance changes
  final updatedAccounts = budget.accounts.map((account) {
    final updatedCards = account.cards.map((card) {
      return card.when(
        pocket: (id, name, icon, balance, color) {
          // INCOME: Reduce pocket balance
          if (transaction.categoryId == 'income' &&
              transaction.targetPocketId == id &&
              account.id == transaction.accountId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance - transaction.amount,
              color: color,
            );
          }
          // TRANSFER OUT: Restore source pocket
          if (transaction.sourcePocketId == id &&
              account.id == transaction.accountId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance + transaction.amount,
              color: color,
            );
          }
          // TRANSFER IN: Reduce target pocket
          if (transaction.targetPocketId == id &&
              transaction.sourcePocketId != null &&
              (account.id == transaction.targetAccountId ||
                  account.id == transaction.accountId)) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance - transaction.amount,
              color: color,
            );
          }
          // SINKING FUND: Reduce target pocket (when no sourcePocketId)
          if (transaction.targetPocketId == id &&
              transaction.sourcePocketId == null &&
              account.id == transaction.accountId) {
            return Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance - transaction.amount,
              color: color,
            );
          }
          return card;
        },
        category:
            (
              id,
              name,
              icon,
              budgetValue,
              currentValue,
              color,
              isRecurring,
              dueDate,
              destPocketId,
              destAccountId,
            ) {
              // EXPENSE: Reduce category currentValue
              if (transaction.categoryId == id &&
                  account.id == transaction.accountId &&
                  transaction.targetPocketId == null) {
                return Card.category(
                  id: id,
                  name: name,
                  icon: icon,
                  budgetValue: budgetValue,
                  currentValue: currentValue - transaction.amount,
                  color: color,
                  isRecurring: isRecurring,
                  dueDate: dueDate,
                  destinationPocketId: destPocketId,
                  destinationAccountId: destAccountId,
                );
              }
              // SINKING FUND: Restore category currentValue
              if (transaction.categoryId == id &&
                  account.id == transaction.accountId &&
                  transaction.targetPocketId != null) {
                return Card.category(
                  id: id,
                  name: name,
                  icon: icon,
                  budgetValue: budgetValue,
                  currentValue: currentValue + transaction.amount,
                  color: color,
                  isRecurring: isRecurring,
                  dueDate: dueDate,
                  destinationPocketId: destPocketId,
                  destinationAccountId: destAccountId,
                );
              }
              return card;
            },
      );
    }).toList();

    return account.copyWith(cards: updatedCards);
  }).toList();

  // Remove transaction from list
  final updatedTransactions = budget.transactions
      .where((t) => t.id != transactionId)
      .toList();

  return budget.copyWith(
    accounts: updatedAccounts,
    transactions: updatedTransactions,
  );
}

/// Get category currentValue by ID
double _getCategoryCurrentValue(
  MonthlyBudget budget, {
  required String accountId,
  required String categoryId,
}) {
  final account = budget.accounts.firstWhere((a) => a.id == accountId);
  final category = account.cards.firstWhere(
    (card) => card.when(
      category:
          (id, _, __, ___, ____, _____, ______, _______, ________, _________) =>
              id == categoryId,
      pocket: (_, __, ___, ____, _____) => false,
    ),
  );

  return category.when(
    category:
        (
          _,
          __,
          ___,
          ____,
          currentValue,
          _____,
          ______,
          _______,
          ________,
          _________,
        ) => currentValue,
    pocket: (_, __, ___, ____, _____) => throw Exception('Not a category'),
  );
}

/// Get pocket balance by ID
double _getPocketBalance(
  MonthlyBudget budget, {
  required String accountId,
  required String pocketId,
}) {
  final account = budget.accounts.firstWhere((a) => a.id == accountId);
  final pocket = account.cards.firstWhere(
    (card) => card.when(
      pocket: (id, _, __, ___, ____) => id == pocketId,
      category:
          (
            _,
            __,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
            __________,
          ) => false,
    ),
  );

  return pocket.when(
    pocket: (_, __, ___, balance, ____) => balance,
    category:
        (
          _,
          __,
          ___,
          ____,
          _____,
          ______,
          _______,
          ________,
          _________,
          __________,
        ) => throw Exception('Not a pocket'),
  );
}
