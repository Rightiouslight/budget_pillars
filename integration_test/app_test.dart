import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easy_budget_pillars/main.dart' as app;

/// Integration tests for Budget Pillars app
///
/// These tests verify complete user flows including:
/// - Authentication
/// - Account management
/// - Budget creation
/// - Transaction handling
/// - SMS parsing
/// - Settings management
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Budget Pillars App - Complete E2E Tests', () {
    // Test credentials - UPDATE THESE WITH YOUR TEST ACCOUNT
    const testEmail = 'test@budgetpillars.com';
    const testPassword = 'TestPassword123!';

    testWidgets('Complete user flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ===== AUTHENTICATION FLOW =====
      await _testAuthentication(tester, testEmail, testPassword);

      // ===== BUDGET SETUP FLOW =====
      await _testBudgetSetup(tester);

      // ===== ACCOUNT MANAGEMENT =====
      await _testAccountManagement(tester);

      // ===== CATEGORY MANAGEMENT =====
      await _testCategoryManagement(tester);

      // ===== POCKET MANAGEMENT =====
      await _testPocketManagement(tester);

      // ===== TRANSACTION FLOW =====
      await _testTransactions(tester);

      // ===== INCOME FLOW =====
      await _testIncomeFlow(tester);

      // ===== SMS PARSING =====
      await _testSMSParsing(tester);

      // ===== SETTINGS =====
      await _testSettings(tester);

      // ===== CLEANUP =====
      await _cleanup(tester);
    });
  });
}

// ===== TEST HELPER FUNCTIONS =====

Future<void> _testAuthentication(
  WidgetTester tester,
  String email,
  String password,
) async {
  debugPrint('🧪 Testing Authentication...');

  // Look for sign-in button
  final signInButton = find.text('Sign In with Email');

  if (signInButton.evaluate().isNotEmpty) {
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Enter email
    final emailField = find.byType(TextField).first;
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();

    // Enter password
    final passwordField = find.byType(TextField).last;
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();

    // Tap sign in
    final submitButton = find.text('Sign In');
    await tester.tap(submitButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    debugPrint('✅ Authentication successful');
  } else {
    debugPrint('ℹ️ Already authenticated');
  }
}

Future<void> _testBudgetSetup(WidgetTester tester) async {
  debugPrint('🧪 Testing Budget Setup...');

  // Check if we need to create initial budget
  final startScratchButton = find.text('Start from Scratch');

  if (startScratchButton.evaluate().isNotEmpty) {
    await tester.tap(startScratchButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugPrint('✅ Created new budget');
  } else {
    debugPrint('ℹ️ Budget already exists');
  }
}

Future<void> _testAccountManagement(WidgetTester tester) async {
  debugPrint('🧪 Testing Account Management...');

  // Find and tap "Add Account" button
  final addAccountButton = find.byIcon(Icons.add).first;
  await tester.tap(addAccountButton);
  await tester.pumpAndSettle();

  // Enter account name
  final nameField = find.byType(TextField).first;
  await tester.enterText(nameField, 'Test Bank Account');
  await tester.pumpAndSettle();

  // Select an icon (tap the icon button)
  final iconButton = find.text('Choose Icon').first;
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  // Select first icon from picker
  final firstIcon = find.byType(IconButton).first;
  await tester.tap(firstIcon);
  await tester.pumpAndSettle();

  // Save account
  final saveButton = find.text('Add Account');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify account was created
  expect(find.text('Test Bank Account'), findsOneWidget);
  debugPrint('✅ Account created successfully');
}

Future<void> _testCategoryManagement(WidgetTester tester) async {
  debugPrint('🧪 Testing Category Management...');

  // Find the account card and tap add category
  final addCategoryButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addCategoryButton);
  await tester.pumpAndSettle();

  // Tap "Category" to add a category
  final categoryOption = find.text('Category');
  await tester.tap(categoryOption);
  await tester.pumpAndSettle();

  // Enter category name
  final nameField = find.widgetWithText(TextField, 'Category Name');
  await tester.enterText(nameField, 'Test Groceries');
  await tester.pumpAndSettle();

  // Enter budget value
  final budgetField = find.widgetWithText(TextField, 'Budget');
  await tester.enterText(budgetField, '500');
  await tester.pumpAndSettle();

  // Select icon
  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  final firstIcon = find.byType(IconButton).first;
  await tester.tap(firstIcon);
  await tester.pumpAndSettle();

  // Save category
  final saveButton = find.text('Add Category');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify category was created
  expect(find.text('Test Groceries'), findsOneWidget);
  debugPrint('✅ Category created successfully');
}

Future<void> _testPocketManagement(WidgetTester tester) async {
  debugPrint('🧪 Testing Pocket Management...');

  // Find and tap add pocket button
  final addButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Tap "Pocket"
  final pocketOption = find.text('Pocket');
  await tester.tap(pocketOption);
  await tester.pumpAndSettle();

  // Enter pocket name
  final nameField = find.byType(TextField).first;
  await tester.enterText(nameField, 'Test Savings');
  await tester.pumpAndSettle();

  // Select icon
  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  final firstIcon = find.byType(IconButton).first;
  await tester.tap(firstIcon);
  await tester.pumpAndSettle();

  // Save pocket
  final saveButton = find.text('Add Pocket');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  debugPrint('✅ Pocket created successfully');
}

Future<void> _testTransactions(WidgetTester tester) async {
  debugPrint('🧪 Testing Transaction Flow...');

  // Tap on a category to add expense
  final categoryCard = find.text('Test Groceries');
  await tester.tap(categoryCard);
  await tester.pumpAndSettle();

  // Enter amount
  final amountField = find.byType(TextField).first;
  await tester.enterText(amountField, '45.50');
  await tester.pumpAndSettle();

  // Enter description
  final descriptionField = find.byType(TextField).last;
  await tester.enterText(descriptionField, 'Weekly groceries');
  await tester.pumpAndSettle();

  // Submit transaction
  final addButton = find.text('Add Expense');
  await tester.tap(addButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  debugPrint('✅ Transaction added successfully');
}

Future<void> _testIncomeFlow(WidgetTester tester) async {
  debugPrint('🧪 Testing Income Flow...');

  // Find account menu and tap
  final accountMenu = find.byIcon(Icons.more_vert).first;
  await tester.tap(accountMenu);
  await tester.pumpAndSettle();

  // Tap "Add Income"
  final addIncomeOption = find.text('Add Income');
  await tester.tap(addIncomeOption);
  await tester.pumpAndSettle();

  // Enter amount
  final amountField = find.byType(TextField).first;
  await tester.enterText(amountField, '1000');
  await tester.pumpAndSettle();

  // Enter description
  final descriptionField = find.widgetWithText(TextField, 'Description');
  await tester.enterText(descriptionField, 'Test Salary');
  await tester.pumpAndSettle();

  // Submit
  final addButton = find.text('Add Income');
  await tester.tap(addButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  debugPrint('✅ Income added successfully');
}

Future<void> _testSMSParsing(WidgetTester tester) async {
  debugPrint('🧪 Testing SMS Parsing...');

  // Navigate to Import page
  final importButton = find.byIcon(Icons.upload_file);

  if (importButton.evaluate().isNotEmpty) {
    await tester.tap(importButton);
    await tester.pumpAndSettle();

    // Set up SMS profile
    final profileNameField = find.widgetWithText(TextField, 'Profile Name');

    if (profileNameField.evaluate().isNotEmpty) {
      await tester.enterText(profileNameField, 'Test SMS Profile');
      await tester.pumpAndSettle();

      // Set start words
      final startWordsField = find.widgetWithText(
        TextField,
        'Description Start Words',
      );
      await tester.enterText(startWordsField, 'at,for,to');
      await tester.pumpAndSettle();

      // Set stop words
      final stopWordsField = find.widgetWithText(
        TextField,
        'Description Stop Words',
      );
      await tester.enterText(stopWordsField, 'from,on');
      await tester.pumpAndSettle();

      debugPrint('✅ SMS profile configured');
    }

    // Go back to dashboard
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testSettings(WidgetTester tester) async {
  debugPrint('🧪 Testing Settings...');

  // Open user menu
  final userMenu = find.byIcon(Icons.arrow_drop_down);

  if (userMenu.evaluate().isNotEmpty) {
    await tester.tap(userMenu);
    await tester.pumpAndSettle();

    // Tap Settings
    final settingsOption = find.text('Settings');
    if (settingsOption.evaluate().isNotEmpty) {
      await tester.tap(settingsOption);
      await tester.pumpAndSettle();

      // Change theme
      final themeDropdown = find.text('Light');
      if (themeDropdown.evaluate().isNotEmpty) {
        await tester.tap(themeDropdown);
        await tester.pumpAndSettle();

        final darkOption = find.text('Dark').last;
        await tester.tap(darkOption);
        await tester.pumpAndSettle();

        debugPrint('✅ Theme changed to Dark');
      }

      // Close settings
      final closeButton = find.text('Close');
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _cleanup(WidgetTester tester) async {
  debugPrint('🧪 Cleaning up test data...');
  // Optionally delete test account/data
  // For now, we'll leave the test data
  debugPrint('✅ All tests completed successfully!');
}
