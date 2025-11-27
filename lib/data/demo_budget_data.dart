import 'models/account.dart';
import 'models/card.dart';
import 'models/monthly_budget.dart';

/// Demo budget data for new users
/// Contains two accounts with sample pockets and categories
class DemoBudgetData {
  /// Creates a demo monthly budget with sample data
  static MonthlyBudget createDemoBudget() {
    final now = DateTime.now();

    // Create IDs using timestamps to ensure uniqueness
    final acc1Id = 'acc_${now.millisecondsSinceEpoch}_1';
    final acc2Id = 'acc_${now.millisecondsSinceEpoch}_2';

    final pocket1Id = 'pocket_${now.millisecondsSinceEpoch}_1';
    final pocket2Id = 'pocket_${now.millisecondsSinceEpoch}_2';
    final savingsId = 'pocket_${now.millisecondsSinceEpoch}_3';

    final cat1Id = 'cat_${now.millisecondsSinceEpoch}_1';
    final cat2Id = 'cat_${now.millisecondsSinceEpoch}_2';
    final cat3Id = 'cat_${now.millisecondsSinceEpoch}_3';
    final cat4Id = 'cat_${now.millisecondsSinceEpoch}_4';
    final cat5Id = 'cat_${now.millisecondsSinceEpoch}_5';

    // Account 1: Main Bank
    final account1 = Account(
      id: acc1Id,
      name: 'Main Bank',
      icon: 'account_balance',
      defaultPocketId: pocket1Id,
      cards: [
        // Default pocket
        Card.pocket(
          id: pocket1Id,
          name: 'Main Bank',
          icon: 'account_balance_wallet',
          balance: 0.0,
          color: '#4CAF50',
        ),
        // Savings pocket
        Card.pocket(
          id: savingsId,
          name: 'Savings',
          icon: 'savings',
          balance: 0.0,
          color: '#2196F3',
        ),
        // Groceries category - BUDGETED
        Card.category(
          id: cat1Id,
          name: 'Groceries',
          icon: 'shopping_cart',
          budgetValue: 400.0,
          currentValue: 0.0,
          color: '#FF9800',
          isRecurring: false,
        ),
        // Rent category - BUDGETED with recurring payment
        Card.category(
          id: cat2Id,
          name: 'Rent',
          icon: 'home',
          budgetValue: 1200.0,
          currentValue: 0.0,
          color: '#9C27B0',
          isRecurring: true,
          dueDate: 1, // Due on the 1st of each month
        ),
        // Transport category
        Card.category(
          id: cat3Id,
          name: 'Transport',
          icon: 'directions_car',
          budgetValue: 150.0,
          currentValue: 0.0,
          color: '#607D8B',
          isRecurring: false,
        ),
      ],
    );

    // Account 2: Credit Card
    final account2 = Account(
      id: acc2Id,
      name: 'Credit Card',
      icon: 'credit_card',
      defaultPocketId: pocket2Id,
      cards: [
        // Default pocket
        Card.pocket(
          id: pocket2Id,
          name: 'Credit Card',
          icon: 'credit_card',
          balance: 0.0,
          color: '#F44336',
        ),
        // Entertainment category
        Card.category(
          id: cat4Id,
          name: 'Entertainment',
          icon: 'movie',
          budgetValue: 100.0,
          currentValue: 0.0,
          color: '#E91E63',
          isRecurring: false,
        ),
        // Utilities category - BUDGETED with recurring payment
        Card.category(
          id: cat5Id,
          name: 'Utilities',
          icon: 'flash_on',
          budgetValue: 200.0,
          currentValue: 0.0,
          color: '#FFEB3B',
          isRecurring: true,
          dueDate: 15, // Due on the 15th of each month
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
}
