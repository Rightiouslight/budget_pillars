import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase/auth_repository.dart';
import '../../data/firebase/firestore_repository.dart';
import '../../data/models/monthly_budget.dart';
import '../../data/models/account.dart';
import '../../data/models/card.dart';
import '../../data/models/transaction.dart';
import '../../providers/active_budget_provider.dart';

/// Provider for the dashboard controller
final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, AsyncValue<void>>((ref) {
      return DashboardController(ref);
    });

/// Controller for managing all budget mutations
class DashboardController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  DashboardController(this._ref) : super(const AsyncValue.data(null));

  FirestoreRepository get _repository => _ref.read(firestoreRepositoryProvider);

  String get _userId => _ref.read(currentUserProvider)!.uid;

  String get _monthKey => _ref.read(activeBudgetInfoProvider)!.monthKey;

  /// Get current budget snapshot
  Future<MonthlyBudget?> _getCurrentBudget() async {
    final budgetAsync = _ref.read(activeBudgetProvider);
    return budgetAsync.value;
  }

  // ===== ACCOUNT OPERATIONS =====

  /// Add a new account with a default pocket
  Future<void> addAccount({required String name, required String icon}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      final accounts = budget?.accounts ?? [];

      final accountId = 'acc_${DateTime.now().millisecondsSinceEpoch}';
      final pocketId = 'pocket_${DateTime.now().millisecondsSinceEpoch}';

      final defaultPocket = Card.pocket(
        id: pocketId,
        name: name,
        icon: icon,
        balance: 0.0,
      );

      final newAccount = Account(
        id: accountId,
        name: name,
        icon: icon,
        defaultPocketId: pocketId,
        cards: [defaultPocket],
      );

      final updatedBudget = MonthlyBudget(
        accounts: [...accounts, newAccount],
        transactions: budget?.transactions ?? [],
        recurringIncomes: budget?.recurringIncomes ?? [],
        autoTransactionsProcessed: budget?.autoTransactionsProcessed ?? {},
        processedRecurringIncomes: budget?.processedRecurringIncomes ?? {},
      );

      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Edit an existing account
  Future<void> editAccount({
    required String accountId,
    required String name,
    required String icon,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          return account.copyWith(name: name, icon: icon);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Delete an account
  Future<void> deleteAccount(String accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts
          .where((account) => account.id != accountId)
          .toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  // ===== POCKET OPERATIONS =====

  /// Add a pocket to an account
  Future<void> addPocket({
    required String accountId,
    required String name,
    required String icon,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final pocketId = 'pocket_${DateTime.now().millisecondsSinceEpoch}';
      final newPocket = Card.pocket(
        id: pocketId,
        name: name,
        icon: icon,
        balance: 0.0,
        color: color,
      );

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          return account.copyWith(cards: [...account.cards, newPocket]);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Edit a pocket
  Future<void> editPocket({
    required String accountId,
    required String pocketId,
    required String name,
    required String icon,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          final updatedCards = account.cards.map((card) {
            return card.when(
              pocket: (id, cardName, cardIcon, balance, cardColor) {
                if (id == pocketId) {
                  return Card.pocket(
                    id: id,
                    name: name,
                    icon: icon,
                    balance: balance,
                    color: color,
                  );
                }
                return card;
              },
              category:
                  (
                    id,
                    cardName,
                    cardIcon,
                    budgetValue,
                    currentValue,
                    cardColor,
                    isRecurring,
                    dueDate,
                    destinationPocketId,
                    destinationAccountId,
                  ) => card,
            );
          }).toList();
          return account.copyWith(cards: updatedCards);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Delete a pocket
  Future<void> deletePocket({
    required String accountId,
    required String pocketId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          final updatedCards = account.cards
              .where(
                (card) => card.when(
                  pocket: (id, _, __, ___, ____) => id != pocketId,
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
                      ) => true,
                ),
              )
              .toList();
          return account.copyWith(cards: updatedCards);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  // ===== CATEGORY OPERATIONS =====

  /// Add a category to an account
  Future<void> addCategory({
    required String accountId,
    required String name,
    required String icon,
    required double budgetValue,
    String? color,
    bool isRecurring = false,
    int? dueDate,
    String? destinationPocketId,
    String? destinationAccountId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final categoryId = 'cat_${DateTime.now().millisecondsSinceEpoch}';
      final newCategory = Card.category(
        id: categoryId,
        name: name,
        icon: icon,
        budgetValue: budgetValue,
        currentValue: 0.0,
        color: color,
        isRecurring: isRecurring,
        dueDate: dueDate,
        destinationPocketId: destinationPocketId,
        destinationAccountId: destinationAccountId,
      );

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          return account.copyWith(cards: [...account.cards, newCategory]);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Edit a category
  Future<void> editCategory({
    required String accountId,
    required String categoryId,
    required String name,
    required String icon,
    required double budgetValue,
    String? color,
    bool isRecurring = false,
    int? dueDate,
    String? destinationPocketId,
    String? destinationAccountId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          final updatedCards = account.cards.map((card) {
            return card.when(
              pocket: (id, cardName, cardIcon, balance, cardColor) => card,
              category:
                  (
                    id,
                    cardName,
                    cardIcon,
                    oldBudgetValue,
                    currentValue,
                    cardColor,
                    oldIsRecurring,
                    oldDueDate,
                    oldDestinationPocketId,
                    oldDestinationAccountId,
                  ) {
                    if (id == categoryId) {
                      return Card.category(
                        id: id,
                        name: name,
                        icon: icon,
                        budgetValue: budgetValue,
                        currentValue: currentValue,
                        color: color,
                        isRecurring: isRecurring,
                        dueDate: dueDate,
                        destinationPocketId: destinationPocketId,
                        destinationAccountId: destinationAccountId,
                      );
                    }
                    return card;
                  },
            );
          }).toList();
          return account.copyWith(cards: updatedCards);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Delete a category
  Future<void> deleteCategory({
    required String accountId,
    required String categoryId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedAccounts = budget.accounts.map((account) {
        if (account.id == accountId) {
          final updatedCards = account.cards
              .where(
                (card) => card.when(
                  pocket: (_, __, ___, ____, _____) => true,
                  category:
                      (
                        id,
                        _,
                        __,
                        ___,
                        ____,
                        _____,
                        ______,
                        _______,
                        ________,
                        _________,
                      ) => id != categoryId,
                ),
              )
              .toList();
          return account.copyWith(cards: updatedCards);
        }
        return account;
      }).toList();

      final updatedBudget = budget.copyWith(accounts: updatedAccounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  // ===== TRANSACTION OPERATIONS =====

  /// Add an expense transaction
  Future<void> addExpense({
    required String accountId,
    required String categoryId,
    required double amount,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      // Find account and category
      final account = budget.accounts.firstWhere((a) => a.id == accountId);
      String? categoryName;
      String? defaultPocketId = account.defaultPocketId;

      // Create transaction
      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        description: description,
        date: DateTime.now(),
        accountId: accountId,
        accountName: account.name,
        categoryId: categoryId,
        categoryName: categoryName ?? '',
        sourcePocketId: defaultPocketId,
      );

      // Update account cards: increase category currentValue, decrease pocket balance
      final updatedAccounts = budget.accounts.map((acc) {
        if (acc.id == accountId) {
          final updatedCards = acc.cards.map((card) {
            return card.when(
              pocket: (id, name, icon, balance, color) {
                if (id == defaultPocketId) {
                  return Card.pocket(
                    id: id,
                    name: name,
                    icon: icon,
                    balance: balance - amount,
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
                    destinationPocketId,
                    destinationAccountId,
                  ) {
                    if (id == categoryId) {
                      categoryName = name;
                      return Card.category(
                        id: id,
                        name: name,
                        icon: icon,
                        budgetValue: budgetValue,
                        currentValue: currentValue + amount,
                        color: color,
                        isRecurring: isRecurring,
                        dueDate: dueDate,
                        destinationPocketId: destinationPocketId,
                        destinationAccountId: destinationAccountId,
                      );
                    }
                    return card;
                  },
            );
          }).toList();
          return acc.copyWith(cards: updatedCards);
        }
        return acc;
      }).toList();

      // Update transaction with category name
      final updatedTransaction = transaction.copyWith(
        categoryName: categoryName ?? '',
      );

      final updatedBudget = budget.copyWith(
        accounts: updatedAccounts,
        transactions: [updatedTransaction, ...budget.transactions],
      );

      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Transfer funds between pockets or from category (refund)
  Future<void> transferFunds({
    required String sourceAccountId,
    required String sourceCardId,
    required bool isSourcePocket, // true = pocket, false = category (refund)
    required String destinationAccountId,
    required String destinationPocketId,
    required double amount,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      String? sourceName;
      String? destinationName;

      // Update cards
      final updatedAccounts = budget.accounts.map((account) {
        final updatedCards = account.cards.map((card) {
          return card.when(
            pocket: (id, name, icon, balance, color) {
              // Decrease source pocket balance
              if (isSourcePocket &&
                  account.id == sourceAccountId &&
                  id == sourceCardId) {
                sourceName = name;
                return Card.pocket(
                  id: id,
                  name: name,
                  icon: icon,
                  balance: balance - amount,
                  color: color,
                );
              }
              // Increase destination pocket balance
              if (account.id == destinationAccountId &&
                  id == destinationPocketId) {
                destinationName = name;
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
                  id,
                  name,
                  icon,
                  budgetValue,
                  currentValue,
                  color,
                  isRecurring,
                  dueDate,
                  destinationPocketId,
                  destinationAccountId,
                ) {
                  // Decrease source category (refund)
                  if (!isSourcePocket &&
                      account.id == sourceAccountId &&
                      id == sourceCardId) {
                    sourceName = name;
                    return Card.category(
                      id: id,
                      name: name,
                      icon: icon,
                      budgetValue: budgetValue,
                      currentValue: currentValue - amount,
                      color: color,
                      isRecurring: isRecurring,
                      dueDate: dueDate,
                      destinationPocketId: destinationPocketId,
                      destinationAccountId: destinationAccountId,
                    );
                  }
                  return card;
                },
          );
        }).toList();
        return account.copyWith(cards: updatedCards);
      }).toList();

      // Create transaction
      final sourceAccount = budget.accounts.firstWhere(
        (a) => a.id == sourceAccountId,
      );

      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        description: description,
        date: DateTime.now(),
        accountId: sourceAccountId,
        accountName: sourceAccount.name,
        categoryId: sourceCardId,
        categoryName: sourceName ?? '',
        targetAccountId: destinationAccountId != sourceAccountId
            ? destinationAccountId
            : null,
        targetPocketId: destinationPocketId,
        targetPocketName: destinationName,
        sourcePocketId: isSourcePocket ? sourceCardId : null,
      );

      final updatedBudget = budget.copyWith(
        accounts: updatedAccounts,
        transactions: [transaction, ...budget.transactions],
      );

      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }
}
