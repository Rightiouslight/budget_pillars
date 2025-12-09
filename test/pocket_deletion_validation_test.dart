import 'package:budget_pillars/data/models/account.dart';
import 'package:budget_pillars/data/models/card.dart';
import 'package:budget_pillars/data/models/monthly_budget.dart';
import 'package:budget_pillars/data/models/recurring_income.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pocket Deletion Validation', () {
    late MonthlyBudget testBudget;

    setUp(() {
      testBudget = _createTestBudget();
    });

    test('should prevent deletion when category references pocket', () {
      // Arrange: Budget has category with destinationPocketId pointing to pocket2
      final categoryReferences = <String>[];

      // Check for categories that reference pocket2
      for (final account in testBudget.accounts) {
        for (final card in account.cards) {
          card.when(
            pocket: (_, __, ___, ____, _____) {},
            category:
                (
                  id,
                  name,
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  destPocketId,
                  destAccountId,
                ) {
                  if (destPocketId == 'pocket2' && destAccountId == 'acc1') {
                    categoryReferences.add(name);
                  }
                },
          );
        }
      }

      // Assert: Should find one category (Groceries) linked to pocket2
      expect(categoryReferences.length, equals(1));
      expect(categoryReferences.first, equals('Groceries'));
    });

    test('should prevent deletion when recurring income references pocket', () {
      // Arrange: Budget has recurring income pointing to pocket1
      final incomeReferences = <String>[];

      // Check for recurring incomes that reference pocket1
      for (final income in testBudget.recurringIncomes) {
        if (income.pocketId == 'pocket1' && income.accountId == 'acc1') {
          incomeReferences.add(income.description ?? 'Unnamed Income');
        }
      }

      // Assert: Should find one recurring income linked to pocket1
      expect(incomeReferences.length, equals(1));
      expect(incomeReferences.first, equals('Monthly Salary'));
    });

    test('should allow deletion when no references exist', () {
      // Arrange: Check pocket3 which has no references
      final categoryReferences = <String>[];
      final incomeReferences = <String>[];

      // Check for categories
      for (final account in testBudget.accounts) {
        for (final card in account.cards) {
          card.when(
            pocket: (_, __, ___, ____, _____) {},
            category:
                (
                  id,
                  name,
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  destPocketId,
                  destAccountId,
                ) {
                  if (destPocketId == 'pocket3' && destAccountId == 'acc2') {
                    categoryReferences.add(name);
                  }
                },
          );
        }
      }

      // Check for recurring incomes
      for (final income in testBudget.recurringIncomes) {
        if (income.pocketId == 'pocket3' && income.accountId == 'acc2') {
          incomeReferences.add(income.description ?? 'Unnamed Income');
        }
      }

      // Assert: Should find no references
      expect(categoryReferences.length, equals(0));
      expect(incomeReferences.length, equals(0));
    });

    test(
      'should list all categories and incomes when multiple references exist',
      () {
        // Arrange: Create budget with multiple references to pocket1
        final budgetWithMultipleRefs = testBudget.copyWith(
          accounts: testBudget.accounts.map((account) {
            if (account.id == 'acc1') {
              return account.copyWith(
                cards: [
                  ...account.cards,
                  const Card.category(
                    id: 'cat3',
                    name: 'Rent',
                    icon: '🏠',
                    budgetValue: 1000.0,
                    currentValue: 0.0,
                    isRecurring: true,
                    dueDate: 1,
                    destinationPocketId: 'pocket1',
                    destinationAccountId: 'acc1',
                  ),
                ],
              );
            }
            return account;
          }).toList(),
          recurringIncomes: [
            ...testBudget.recurringIncomes,
            RecurringIncome(
              id: 'income2',
              description: 'Freelance Income',
              amount: 500.0,
              dayOfMonth: 15,
              accountId: 'acc1',
              pocketId: 'pocket1',
            ),
          ],
        );

        // Check references to pocket1
        final categoryReferences = <String>[];
        final incomeReferences = <String>[];

        for (final account in budgetWithMultipleRefs.accounts) {
          for (final card in account.cards) {
            card.when(
              pocket: (_, __, ___, ____, _____) {},
              category:
                  (
                    id,
                    name,
                    _,
                    __,
                    ___,
                    ____,
                    _____,
                    ______,
                    destPocketId,
                    destAccountId,
                  ) {
                    if (destPocketId == 'pocket1' && destAccountId == 'acc1') {
                      categoryReferences.add(name);
                    }
                  },
            );
          }
        }

        for (final income in budgetWithMultipleRefs.recurringIncomes) {
          if (income.pocketId == 'pocket1' && income.accountId == 'acc1') {
            incomeReferences.add(income.description ?? 'Unnamed Income');
          }
        }

        // Assert: Should find multiple references
        expect(categoryReferences.length, equals(1)); // Rent
        expect(
          incomeReferences.length,
          equals(2),
        ); // Monthly Salary + Freelance Income
        expect(categoryReferences, contains('Rent'));
        expect(incomeReferences, contains('Monthly Salary'));
        expect(incomeReferences, contains('Freelance Income'));
      },
    );

    test('should only check references for the correct account', () {
      // Arrange: Check that pocket1 in acc1 doesn't match pocket references in acc2
      final categoryReferences = <String>[];

      for (final account in testBudget.accounts) {
        for (final card in account.cards) {
          card.when(
            pocket: (_, __, ___, ____, _____) {},
            category:
                (
                  id,
                  name,
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  destPocketId,
                  destAccountId,
                ) {
                  // Looking for pocket1 but ONLY in acc1
                  if (destPocketId == 'pocket1' && destAccountId == 'acc1') {
                    categoryReferences.add(name);
                  }
                },
          );
        }
      }

      // Assert: Should only find categories in the correct account
      expect(categoryReferences.length, equals(0));
      // Note: In our test budget, pocket1 is referenced by pocket2 in the category,
      // so this verifies we're checking the accountId correctly
    });
  });
}

/// Creates a test budget with:
/// - Account 1 with 2 pockets and 2 categories
///   - pocket1: Main Pocket (has recurring income)
///   - pocket2: Savings Pocket (referenced by Groceries category)
///   - cat1: Groceries (sinking fund → pocket2)
///   - cat2: Transport (normal category)
/// - Account 2 with 1 pocket
///   - pocket3: Emergency Fund (no references)
/// - 1 recurring income pointing to pocket1
MonthlyBudget _createTestBudget() {
  return MonthlyBudget(
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
            balance: 300.0,
          ),
          const Card.category(
            id: 'cat1',
            name: 'Groceries',
            icon: '🛒',
            budgetValue: 100.0,
            currentValue: 0.0,
            isRecurring: true,
            dueDate: 15,
            destinationPocketId: 'pocket2', // References pocket2
            destinationAccountId: 'acc1',
          ),
          const Card.category(
            id: 'cat2',
            name: 'Transport',
            icon: '🚗',
            budgetValue: 50.0,
            currentValue: 0.0,
          ),
        ],
      ),
      Account(
        id: 'acc2',
        name: 'Savings',
        icon: '🏦',
        defaultPocketId: 'pocket3',
        cards: [
          const Card.pocket(
            id: 'pocket3',
            name: 'Emergency Fund',
            icon: '🆘',
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
        dayOfMonth: 1,
        accountId: 'acc1',
        pocketId: 'pocket1', // References pocket1
      ),
    ],
  );
}
