# Integration Tests for Budget Pillars

This directory contains end-to-end integration tests that verify complete user workflows.

## Test Coverage

The integration tests cover:

✅ **Authentication Flow**

- Sign in with email/password
- User session persistence

✅ **Budget Setup**

- Initial budget creation
- Budget initialization

✅ **Account Management**

- Create account
- Icon selection from picker
- Account display

✅ **Category Management**

- Add category to account
- Set budget value
- Icon and color selection

✅ **Pocket Management**

- Create savings pocket
- Icon and color selection
- Pocket allocation

✅ **Transaction Flow**

- Add expense to category
- Amount and description entry
- Date selection
- Transaction persistence

✅ **Income Flow**

- Add one-time income
- Income allocation to accounts

✅ **SMS Parsing**

- SMS profile configuration
- Start/stop words setup
- Transaction extraction from SMS

✅ **Settings**

- Theme changes
- User preferences
- Settings persistence

## Prerequisites

1. **Test Account**: Create a Firebase test account with these credentials:

   - Email: `test@budgetpillars.com`
   - Password: `TestPassword123!`

2. **Update Credentials**: Edit `app_test.dart` and update:

   ```dart
   const testEmail = 'YOUR_TEST_EMAIL';
   const testPassword = 'YOUR_TEST_PASSWORD';
   ```

3. **Dependencies**: Ensure `integration_test` is in `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     integration_test:
       sdk: flutter
   ```

## Running Tests

### Run all integration tests

```powershell
flutter test integration_test/app_test.dart
```

### Run on specific device

```powershell
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/app_test.dart -d <device_id>
```

### Run on Chrome (Web)

```powershell
flutter test integration_test/app_test.dart -d chrome --web-renderer html
```

### Run on Android emulator

```powershell
flutter test integration_test/app_test.dart -d emulator-5554
```

### Run on iOS simulator

```powershell
flutter test integration_test/app_test.dart -d "iPhone 15 Pro"
```

## Test Output

Tests will print debug messages showing progress:

- 🧪 Testing [Feature]...
- ✅ [Feature] successful
- ℹ️ [Info message]

Example output:

```
🧪 Testing Authentication...
✅ Authentication successful
🧪 Testing Budget Setup...
ℹ️ Budget already exists
🧪 Testing Account Management...
✅ Account created successfully
...
✅ All tests completed successfully!
```

## Test Data Cleanup

Currently, tests create data but **do not** automatically clean up. To reset:

1. **Manual Cleanup**: Sign in with test account and delete test data
2. **Firestore Console**: Delete test user's data directly
3. **Future Enhancement**: Implement automated cleanup in `_cleanup()` function

## Troubleshooting

### Tests fail at authentication

- Verify test account exists in Firebase
- Check credentials are correct
- Ensure Firebase is configured properly

### Tests timeout

- Increase timeout in test: `await tester.pumpAndSettle(Duration(seconds: 10));`
- Check network connectivity
- Verify Firebase services are running

### Widget not found errors

- UI may have changed - update test selectors
- Check if widgets are visible/scrolled into view
- Add debug prints to verify widget tree

### SMS parsing fails

- Ensure SMS profile is configured
- Check start/stop words match your SMS format
- Test SMS format manually first

## Adding New Tests

To test a new feature:

1. Add test function in `app_test.dart`:

   ```dart
   Future<void> _testMyNewFeature(WidgetTester tester) async {
     debugPrint('🧪 Testing My New Feature...');

     // Your test code here

     debugPrint('✅ My New Feature successful');
   }
   ```

2. Call it in main test:

   ```dart
   await _testMyNewFeature(tester);
   ```

3. Run and verify:
   ```powershell
   flutter test integration_test/app_test.dart
   ```

## Best Practices

- ✅ Use `pumpAndSettle()` after UI interactions
- ✅ Add reasonable timeouts for async operations
- ✅ Verify results with `expect()` assertions
- ✅ Use descriptive test names and debug messages
- ✅ Test happy path and edge cases
- ✅ Keep tests independent and idempotent
- ❌ Don't rely on specific test execution order
- ❌ Don't hardcode device-specific values
- ❌ Don't skip cleanup (implement proper teardown)

## CI/CD Integration

To run tests in CI pipeline:

```yaml
# Example GitHub Actions
- name: Run Integration Tests
  run: flutter test integration_test/app_test.dart
```

## Additional Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [Integration Test Package](https://pub.dev/packages/integration_test)
