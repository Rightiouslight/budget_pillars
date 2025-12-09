# Unit Tests - Transaction Functionality

## Overview

This directory contains unit tests that verify all transaction operations correctly update pockets and categories. These tests ensure the core financial logic of the Budget Pillars app works correctly.

## Test Coverage

### ✅ Add Expense Transaction (3 tests)

- Reduces category `currentValue` by expense amount
- Does not affect pocket balances
- Creates transaction with correct details

### ✅ Add Income Transaction (2 tests)

- Increases target pocket balance by income amount
- Creates transaction with `categoryId="income"`

### ✅ Transfer Between Pockets (3 tests)

- Decreases source pocket and increases target pocket
- Creates transaction with both source and target pocket IDs
- Works across different accounts

### ✅ Sinking Fund Transfer (2 tests)

- Reduces category `currentValue` and increases pocket balance
- Creates transaction with categoryId and targetPocketId

### ✅ Delete Transaction (5 tests)

- **Reverts expense**: Decreases category currentValue
- **Reverts income**: Decreases pocket balance
- **Reverts transfer**: Restores both pocket balances
- **Reverts sinking fund**: Restores category and pocket
- **Removes transaction** from list

### ✅ Edge Cases (4 tests)

- Handles zero amount transactions
- Handles decimal amounts correctly
- Allows negative category balances (overspending)
- Maintains pocket balance precision across multiple transactions

## Total: 19 Unit Tests

## Running the Tests

### Run all unit tests

```powershell
flutter test test/dashboard_controller_test.dart
```

### Run all tests in the project

```powershell
flutter test
```

### Run with coverage

```powershell
flutter test --coverage
```

## Test Structure

Each test follows the **Arrange-Act-Assert** pattern:

```dart
test('reduces category currentValue by expense amount', () {
  // Arrange: Set up initial state
  final initialCategoryValue = _getCategoryCurrentValue(...);

  // Act: Perform the operation
  final updatedBudget = _simulateAddExpense(...);

  // Assert: Verify the result
  final finalCategoryValue = _getCategoryCurrentValue(...);
  expect(finalCategoryValue, equals(initialCategoryValue + 50.0));
});
```

## Helper Functions

The test file includes simulation functions that mirror the actual business logic:

- `_simulateAddExpense()` - Simulates adding an expense transaction
- `_simulateAddIncome()` - Simulates adding income
- `_simulateTransferBetweenPockets()` - Simulates pocket-to-pocket transfer
- `_simulateSinkingFundTransfer()` - Simulates category-to-pocket transfer
- `_simulateDeleteTransaction()` - Simulates transaction deletion
- `_getCategoryCurrentValue()` - Gets current value for a category
- `_getPocketBalance()` - Gets balance for a pocket
- `_createTestBudget()` - Creates test budget with 2 accounts, 4 cards

## Test Budget Structure

The tests use a standardized test budget:

```
Account 1: Checking (acc1)
├── Pocket 1: Main Pocket (pocket1) - $500
├── Pocket 2: Savings Pocket (pocket2) - $300
├── Category 1: Groceries (cat1) - Budget: $100, Current: $0
└── Category 2: Transport (cat2) - Budget: $50, Current: $0

Account 2: Savings (acc2)
└── Pocket 3: Emergency Fund (pocket3) - $1000
```

## Integration with CI/CD

Add these tests to your CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
```

## Why Unit Tests?

1. **Fast Execution**: Unit tests run in milliseconds
2. **Isolated Testing**: Tests specific business logic without UI or Firebase
3. **Early Bug Detection**: Catch issues before integration testing
4. **Regression Prevention**: Ensure changes don't break existing functionality
5. **Documentation**: Tests serve as living documentation of expected behavior

## Relationship to Integration Tests

| Type                  | Purpose                          | Speed            | Coverage             |
| --------------------- | -------------------------------- | ---------------- | -------------------- |
| **Unit Tests**        | Test business logic in isolation | Very Fast (< 1s) | Transaction logic    |
| **Integration Tests** | Test complete user flows with UI | Slow (30-60s)    | End-to-end workflows |

Both types are important:

- Run **unit tests** frequently during development
- Run **integration tests** before commits/deploys

## Expected Output

```
00:02 +19: All tests passed!
```

## Troubleshooting

### Tests fail after model changes

- Update helper functions to match new model structure
- Check freezed models are generated: `flutter pub run build_runner build`

### Precision issues with decimal numbers

- The tests use exact equality which works for most cases
- If you encounter floating-point precision issues, use `closeTo()` matcher:
  ```dart
  expect(finalBalance, closeTo(expected, 0.01));
  ```

### Tests pass locally but fail in CI

- Ensure Flutter version matches
- Run `flutter clean` and `flutter pub get`

## Contributing

When adding new transaction features:

1. Add test cases for the new functionality
2. Add test cases for edge cases
3. Update this README with new test coverage
4. Ensure all tests pass before committing

## Next Steps

Consider adding unit tests for:

- [ ] Recurring income processing
- [ ] Automatic transaction processing
- [ ] Budget import/export logic
- [ ] Category budget allocation
- [ ] Account deletion cascading logic
