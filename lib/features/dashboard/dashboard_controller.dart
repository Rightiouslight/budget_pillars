import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase/auth_repository.dart';
import '../../data/firebase/firestore_repository.dart';
import '../../data/models/monthly_budget.dart';
import '../../data/models/account.dart';
import '../../data/models/card.dart';
import '../../data/models/transaction.dart';
import '../../data/models/recurring_income.dart';
import '../../data/models/budget_notification.dart';
import '../../providers/active_budget_provider.dart';
import '../../providers/user_settings_provider.dart';
import 'automatic_transaction_processor.dart';

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

  // ===== INCOME OPERATIONS =====

  /// Add income to a pocket
  Future<void> addIncome({
    required String accountId,
    required String pocketId,
    required double amount,
    required String description,
    DateTime? date,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final incomeDate = date ?? DateTime.now();

      // Find the account and pocket
      final accountIndex = budget.accounts.indexWhere(
        (account) => account.id == accountId,
      );
      if (accountIndex == -1) return;

      final account = budget.accounts[accountIndex];
      final pocketIndex = account.cards.indexWhere(
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
      if (pocketIndex == -1) return;

      // Update pocket balance
      final updatedCards = List<Card>.from(account.cards);
      final pocket = updatedCards[pocketIndex];
      updatedCards[pocketIndex] = pocket.when(
        pocket: (id, name, icon, balance, color) {
          return Card.pocket(
            id: id,
            name: name,
            icon: icon,
            balance: balance + amount,
            color: color,
          );
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
            ) => pocket,
      );

      // Create transaction
      final transaction = Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        description: description,
        date: incomeDate,
        accountId: accountId,
        accountName: account.name,
        categoryId: 'income',
        categoryName:
            'Income to ${pocket.when(pocket: (_, name, __, ___, ____) => name, category: (_, __, ___, ____, _____, ______, _______, ________, _________, __________) => '')}',
        targetPocketId: pocketId,
        targetPocketName: pocket.when(
          pocket: (_, name, __, ___, ____) => name,
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
              ) => '',
        ),
      );

      // Update budget
      final accounts = List<Account>.from(budget.accounts);
      accounts[accountIndex] = account.copyWith(cards: updatedCards);

      final updatedBudget = budget.copyWith(
        accounts: accounts,
        transactions: [transaction, ...budget.transactions],
      );

      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Save or update a recurring income
  Future<void> saveRecurringIncome({
    String? id,
    required String accountId,
    required String pocketId,
    required double amount,
    required String description,
    required int dayOfMonth,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final recurringIncomes = List<RecurringIncome>.from(
        budget.recurringIncomes,
      );

      RecurringIncome newOrUpdatedIncome;

      if (id != null) {
        // Update existing recurring income
        final index = recurringIncomes.indexWhere((income) => income.id == id);
        if (index != -1) {
          newOrUpdatedIncome = RecurringIncome(
            id: id,
            description: description,
            amount: amount,
            accountId: accountId,
            pocketId: pocketId,
            dayOfMonth: dayOfMonth,
          );
          recurringIncomes[index] = newOrUpdatedIncome;
        } else {
          return; // Income not found
        }
      } else {
        // Add new recurring income
        newOrUpdatedIncome = RecurringIncome(
          id: 'rec_inc_${DateTime.now().millisecondsSinceEpoch}',
          description: description,
          amount: amount,
          accountId: accountId,
          pocketId: pocketId,
          dayOfMonth: dayOfMonth,
        );
        recurringIncomes.add(newOrUpdatedIncome);
      }

      var updatedBudget = budget.copyWith(recurringIncomes: recurringIncomes);

      // If dayOfMonth is 99 (immediate), process the income now
      if (id == null && dayOfMonth == 99) {
        // Find the account and pocket
        final accountIndex = updatedBudget.accounts.indexWhere(
          (a) => a.id == accountId,
        );
        if (accountIndex != -1) {
          final account = updatedBudget.accounts[accountIndex];
          final pocketIndex = account.cards.indexWhere(
            (c) => c.id == pocketId && c is PocketCard,
          );

          if (pocketIndex != -1) {
            final pocket = account.cards[pocketIndex] as PocketCard;

            // Update pocket balance
            final updatedPocket = pocket.copyWith(
              balance: pocket.balance + amount,
            );

            final updatedCards = List<Card>.from(account.cards);
            updatedCards[pocketIndex] = updatedPocket;

            final updatedAccount = account.copyWith(cards: updatedCards);
            final updatedAccounts = List<Account>.from(updatedBudget.accounts);
            updatedAccounts[accountIndex] = updatedAccount;

            // Create transaction
            final transaction = Transaction(
              id: 'txn_${DateTime.now().millisecondsSinceEpoch}_immediate_${newOrUpdatedIncome.id}',
              amount: amount,
              description: description,
              date: DateTime.now(),
              accountId: accountId,
              accountName: account.name,
              categoryId: pocketId,
              categoryName: 'Income to ${pocket.name}',
              sourcePocketId: pocketId,
            );

            // Create notification
            final notification = BudgetNotification(
              id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
              type: NotificationType.recurringIncome,
              title: 'Income Deposited',
              message:
                  '$description: \$${amount.toStringAsFixed(2)} → ${pocket.name}',
              timestamp: DateTime.now(),
              relatedTransactionId: transaction.id,
            );

            // Update budget with transaction, processed flag, and notification
            updatedBudget = updatedBudget.copyWith(
              accounts: updatedAccounts,
              transactions: [transaction, ...updatedBudget.transactions],
              processedRecurringIncomes: {
                ...updatedBudget.processedRecurringIncomes,
                newOrUpdatedIncome.id: true,
              },
              notifications: [notification, ...updatedBudget.notifications],
            );
          }
        }
      }

      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Delete a recurring income
  Future<void> deleteRecurringIncome(String incomeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final recurringIncomes = budget.recurringIncomes
          .where((income) => income.id != incomeId)
          .toList();

      final updatedBudget = budget.copyWith(recurringIncomes: recurringIncomes);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Process all due automatic transactions (recurring expenses and incomes)
  ///
  /// This method should be called when:
  /// - Budget loads for the first time
  /// - App starts
  /// - Month changes
  ///
  /// It will silently process all due transactions and create notifications.
  Future<void> processAutomaticTransactions() async {
    // Don't show loading state - this runs silently in the background
    final budget = await _getCurrentBudget();
    if (budget == null) return;

    // Get month start date from settings
    final settings = await _ref.read(userSettingsProvider.future);

    // Import the processor
    final result = await Future(() {
      return AutomaticTransactionProcessor.processAutomaticTransactions(
        budget: budget,
        monthStartDate: settings.monthStartDate,
      );
    });

    // Only save if there were changes
    if (result.hasChanges || result.hasErrors) {
      await _repository.saveBudget(_userId, _monthKey, result.updatedBudget);

      // Force reload the budget to reflect changes
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        // The budget will be reloaded by the provider
      });
    }
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
    DateTime? date,
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
        date: date ?? DateTime.now(),
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

  // ===== RECURRING EXPENSE OPERATIONS =====

  /// Quick Pay for a recurring category - pays the remaining budgeted amount
  /// If category has destinationPocketId (sinking fund), transfers to that pocket
  /// Otherwise, logs as a regular expense
  Future<void> quickPayCategory({
    required String accountId,
    required String categoryId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      // Find the account and category
      final account = budget.accounts.firstWhere((a) => a.id == accountId);

      // Find the category card
      final categoryCard = account.cards.firstWhere((card) {
        return card.when(
          pocket: (_, __, ___, ____, _____) => false,
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
              ) => id == categoryId,
        );
      });

      String? categoryName;
      double? budgetValue;
      double? currentValue;
      String? destinationPocketId;
      String? destinationAccountId;

      categoryCard.when(
        pocket: (_, __, ___, ____, _____) {},
        category:
            (
              id,
              name,
              icon,
              budgetVal,
              currentVal,
              color,
              isRecurring,
              dueDate,
              destPocketId,
              destAcctId,
            ) {
              categoryName = name;
              budgetValue = budgetVal;
              currentValue = currentVal;
              destinationPocketId = destPocketId;
              destinationAccountId = destAcctId;
            },
      );

      final remainingAmount = (budgetValue ?? 0.0) - (currentValue ?? 0.0);

      if (remainingAmount <= 0) {
        // Nothing to pay
        return;
      }

      // Check if this is a sinking fund (has destination pocket)
      if (destinationPocketId != null) {
        // Transfer to destination pocket instead of expense
        final targetAccountId = destinationAccountId ?? accountId;

        await transferFunds(
          sourceAccountId: accountId,
          sourceCardId: account.defaultPocketId,
          isSourcePocket: true,
          destinationAccountId: targetAccountId,
          destinationPocketId: destinationPocketId!,
          amount: remainingAmount,
          description: 'Sinking Fund: $categoryName',
        );
      } else {
        // Regular expense
        await addExpense(
          accountId: accountId,
          categoryId: categoryId,
          amount: remainingAmount,
          description: 'Quick Pay: $categoryName',
        );
      }
    });
  }

  /// Process automatic payments for all recurring categories that are due
  /// Should be called on app startup
  Future<void> processAutomaticPayments() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final now = DateTime.now();
      final autoProcessed = Map<String, bool>.from(
        budget.autoTransactionsProcessed,
      );
      bool hasUpdates = false;

      for (final account in budget.accounts) {
        for (final card in account.cards) {
          await card.when(
            pocket: (_, __, ___, ____, _____) async {},
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
                  destAcctId,
                ) async {
                  // Only process recurring categories with due dates
                  if (!isRecurring || dueDate == null) return;

                  // Check if already processed this month
                  final processKey = '$_monthKey:$id';
                  if (autoProcessed.containsKey(processKey)) return;

                  // Calculate due date for current budget period
                  final categoryDueDate = DateTime(
                    now.year,
                    now.month,
                    dueDate,
                  );

                  // If we're past the due date and haven't processed yet
                  if (now.isAfter(categoryDueDate) ||
                      now.isAtSameMomentAs(categoryDueDate)) {
                    await quickPayCategory(
                      accountId: account.id,
                      categoryId: id,
                    );

                    // Mark as processed
                    autoProcessed[processKey] = true;
                    hasUpdates = true;
                  }
                },
          );
        }
      }

      // Save updated auto-processed map if there were changes
      if (hasUpdates) {
        final updatedBudget = budget.copyWith(
          autoTransactionsProcessed: autoProcessed,
        );
        await _repository.saveBudget(_userId, _monthKey, updatedBudget);
      }
    });
  }

  // ===== REORDERING OPERATIONS =====

  /// Reorder accounts horizontally
  Future<void> reorderAccounts({
    required int oldIndex,
    required int newIndex,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final accounts = List<Account>.from(budget.accounts);

      // Adjust newIndex if moving down
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Reorder accounts
      final account = accounts.removeAt(oldIndex);
      accounts.insert(newIndex, account);

      final updatedBudget = budget.copyWith(accounts: accounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Reorder cards within an account
  Future<void> reorderCards({
    required int accountIndex,
    required int oldIndex,
    required int newIndex,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null || accountIndex >= budget.accounts.length) return;

      final accounts = List<Account>.from(budget.accounts);
      final account = accounts[accountIndex];
      final cards = List<Card>.from(account.cards);

      // Adjust newIndex if moving down
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Reorder cards
      final card = cards.removeAt(oldIndex);
      cards.insert(newIndex, card);

      // Update account with reordered cards
      final updatedAccount = account.copyWith(cards: cards);
      accounts[accountIndex] = updatedAccount;

      final updatedBudget = budget.copyWith(accounts: accounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Update multiple category budgets at once (from Budget Planner)
  Future<void> updateCategoryBudgets({
    required String accountId,
    required Map<String, double> categoryBudgets,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final accounts = List<Account>.from(budget.accounts);
      final accountIndex = accounts.indexWhere(
        (account) => account.id == accountId,
      );
      if (accountIndex == -1) return;

      final account = accounts[accountIndex];
      final updatedCards = account.cards.map((card) {
        return card.maybeWhen(
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
                // If this category has a new budget value, update it
                if (categoryBudgets.containsKey(id)) {
                  return Card.category(
                    id: id,
                    name: name,
                    icon: icon,
                    budgetValue: categoryBudgets[id]!,
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
          orElse: () => card,
        );
      }).toList();

      final updatedAccount = account.copyWith(cards: updatedCards);
      accounts[accountIndex] = updatedAccount;

      final updatedBudget = budget.copyWith(accounts: accounts);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }
}
