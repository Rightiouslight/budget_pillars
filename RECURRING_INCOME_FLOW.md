# Recurring Income Flow - Complete Explanation

## Overview

The recurring income system allows users to schedule income deposits that happen automatically on a specific day of each month. There are two types of recurring income setups:

1. **Immediate** (dayOfMonth = 99): Processes right away AND sets up future recurring deposits
2. **Scheduled** (dayOfMonth = 1-28): Only sets up the recurring schedule, processes on the specified day

## Data Structure

### RecurringIncome Model

```dart
class RecurringIncome {
  String id;                // Unique ID: 'rec_inc_{timestamp}'
  String? name;             // Legacy field (not used)
  String? description;      // Display name/description
  double amount;            // Amount to deposit
  String? accountId;        // Target account
  String? pocketId;         // Target pocket within the account
  int dayOfMonth;           // 99 = Immediate, 1-28 = Specific day
}
```

### MonthlyBudget Tracking

```dart
class MonthlyBudget {
  List<RecurringIncome> recurringIncomes;              // All recurring income definitions
  Map<String, bool> processedRecurringIncomes;         // Tracks which have been processed this month
  // Key format: '{recurringIncomeId}' → true/false
}
```

## User Flow

### When User Saves a Recurring Income

**From AddIncomeDialog:**

1. User fills in:

   - Amount (e.g., $3000)
   - Description (e.g., "Monthly Salary")
   - Target pocket (e.g., "Main Pocket")
   - Recurring toggle: **ON**
   - Deposit Day: Either "Immediately" (99) or Day 1-28

2. User clicks "Add Income"

3. System calls:

```dart
dashboardController.saveRecurringIncome(
  accountId: account.id,
  pocketId: selectedPocketId,
  amount: 3000.00,
  description: "Monthly Salary",
  dayOfMonth: 99, // or 1-28
)
```

### What Happens in saveRecurringIncome()

**Current Implementation (dashboard_controller.dart):**

```dart
Future<void> saveRecurringIncome({...}) async {
  // 1. Get current month's budget
  final budget = await _getCurrentBudget();

  // 2. Add the recurring income definition to the list
  final newIncome = RecurringIncome(
    id: 'rec_inc_${DateTime.now().millisecondsSinceEpoch}',
    description: description,
    amount: amount,
    accountId: accountId,
    pocketId: pocketId,
    dayOfMonth: dayOfMonth, // 99 or 1-28
  );

  recurringIncomes.add(newIncome);

  // 3. Save updated budget to Firestore
  await repository.saveBudget(userId, monthKey, updatedBudget);
}
```

**⚠️ ISSUE: This only saves the DEFINITION, it doesn't process the income!**

## How It SHOULD Work (Based on Requirements)

### For Immediate Income (dayOfMonth = 99)

When user selects "Immediately":

1. **Save the recurring definition** (as currently done)
2. **IMMEDIATELY process the first deposit:**
   ```dart
   // After saving the recurring income definition:
   if (dayOfMonth == 99) {
     // Create the actual transaction NOW
     await addIncome(
       accountId: accountId,
       pocketId: pocketId,
       amount: amount,
       description: description,
       date: DateTime.now(),
     );

     // Mark as processed for this month
     processedRecurringIncomes[newIncome.id] = true;
   }
   ```

### For Scheduled Income (dayOfMonth = 1-28)

When user selects a specific day (e.g., Day 15):

1. **Save the recurring definition** (as currently done)
2. **DO NOT process immediately**
3. Wait for the automatic processing system to handle it

## Automatic Processing System (NOT YET IMPLEMENTED)

### When It Runs

The system should check recurring incomes:

- **On app startup**
- **On month change**
- **Daily (if app is running)**

### Processing Logic

```dart
Future<void> processRecurringIncomes() async {
  final budget = await _getCurrentBudget();
  final today = DateTime.now();
  final currentDay = today.day;

  for (final recurringIncome in budget.recurringIncomes) {
    // Skip if already processed this month
    if (budget.processedRecurringIncomes[recurringIncome.id] == true) {
      continue;
    }

    // Skip if it's an "immediate" type (dayOfMonth = 99)
    if (recurringIncome.dayOfMonth == 99) {
      continue; // These are processed when created
    }

    // Check if today is the due date or later
    if (currentDay >= recurringIncome.dayOfMonth) {
      // Create the income transaction
      await addIncome(
        accountId: recurringIncome.accountId!,
        pocketId: recurringIncome.pocketId!,
        amount: recurringIncome.amount,
        description: recurringIncome.description ?? 'Recurring Income',
        date: DateTime(today.year, today.month, recurringIncome.dayOfMonth),
      );

      // Mark as processed
      final updatedProcessed = {
        ...budget.processedRecurringIncomes,
        recurringIncome.id: true,
      };

      final updatedBudget = budget.copyWith(
        processedRecurringIncomes: updatedProcessed,
      );

      await repository.saveBudget(userId, monthKey, updatedBudget);
    }
  }
}
```

### Where to Call It

**In main.dart or app initialization:**

```dart
class BudgetPillarsApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for user auth state
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        // User just logged in - process recurring items
        ref.read(dashboardControllerProvider.notifier)
           .processRecurringIncomes();
      }
    });

    // Also listen for month changes
    ref.listen(activeBudgetProvider, (previous, next) {
      // If month changed, process recurring items for new month
      if (previous?.monthKey != next?.monthKey) {
        ref.read(dashboardControllerProvider.notifier)
           .processRecurringIncomes();
      }
    });

    return MaterialApp.router(...);
  }
}
```

## Month Rollover Behavior

### What Happens When a New Month Starts

1. **processedRecurringIncomes map is FRESH/EMPTY** for the new month
2. When user switches to the new month or app starts in new month:

   - System loads budget for new month (e.g., "2025-12")
   - Finds empty `processedRecurringIncomes` map
   - Runs `processRecurringIncomes()`
   - Processes all recurring incomes that are due

3. **Example:**
   - Recurring Income: "Salary", $3000, Day 15
   - User opens app on Dec 20
   - System checks: `currentDay (20) >= dayOfMonth (15)` → TRUE
   - System checks: `processedRecurringIncomes['rec_inc_123']` → FALSE (not processed)
   - **DEPOSITS $3000** and marks as processed

## UI Integration

### Income Management Screen (Should Be Created)

Users need a way to view and manage their recurring incomes:

```dart
class RecurringIncomesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);

    return budgetAsync.when(
      data: (budget) {
        return ListView.builder(
          itemCount: budget.recurringIncomes.length,
          itemBuilder: (context, index) {
            final income = budget.recurringIncomes[index];
            final isProcessed = budget.processedRecurringIncomes[income.id] ?? false;

            return ListTile(
              leading: Icon(
                income.dayOfMonth == 99
                  ? Icons.flash_on
                  : Icons.calendar_today
              ),
              title: Text(income.description ?? 'Income'),
              subtitle: Text(
                income.dayOfMonth == 99
                  ? 'Immediate deposit'
                  : 'Deposits on day ${income.dayOfMonth}'
              ),
              trailing: Column(
                children: [
                  Text('\$${income.amount.toStringAsFixed(2)}'),
                  if (isProcessed)
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
              onTap: () => _showEditDialog(context, income),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

## Summary of Changes Needed

### 1. Fix saveRecurringIncome() in dashboard_controller.dart

```dart
Future<void> saveRecurringIncome({...}) async {
  // ... existing code to add to recurringIncomes list ...

  // NEW: If dayOfMonth is 99, process immediately
  if (dayOfMonth == 99) {
    await addIncome(
      accountId: accountId,
      pocketId: pocketId,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    // Mark as processed
    updatedBudget = updatedBudget.copyWith(
      processedRecurringIncomes: {
        ...updatedBudget.processedRecurringIncomes,
        newIncome.id: true,
      },
    );
  }

  await repository.saveBudget(userId, monthKey, updatedBudget);
}
```

### 2. Add processRecurringIncomes() method

Add the automatic processing logic shown above to dashboard_controller.dart

### 3. Call Processing on App Events

Add listeners in app.dart or appropriate initialization point

### 4. Create Recurring Incomes Management UI

Allow users to view, edit, and delete their recurring incomes

## Key Behaviors

| Scenario                                         | Behavior                                                              |
| ------------------------------------------------ | --------------------------------------------------------------------- |
| User creates "Immediate" recurring income        | Deposits money NOW + creates recurring definition                     |
| User creates "Day 15" recurring income on Dec 10 | Only creates definition, no deposit yet                               |
| User creates "Day 15" recurring income on Dec 20 | Creates definition, automatic processor deposits it on next app start |
| App starts on Dec 16, income set for Day 15      | Deposits money (if not already processed)                             |
| User switches to new month                       | System processes all due recurring incomes for that month             |
| Recurring income already processed this month    | Skipped (checked via processedRecurringIncomes map)                   |

## Status: PARTIALLY IMPLEMENTED ⚠️

**What Works:**

- ✅ Saving recurring income definitions
- ✅ Editing recurring income definitions
- ✅ Deleting recurring income definitions
- ✅ Data structure supports tracking

**What's Missing:**

- ❌ Immediate processing (dayOfMonth = 99)
- ❌ Automatic processing system
- ❌ App startup checks
- ❌ Month change checks
- ❌ Management UI to view recurring incomes
- ❌ Visual indicators showing which incomes have been processed
