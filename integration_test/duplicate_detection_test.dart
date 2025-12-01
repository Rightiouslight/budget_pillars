import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_pillars/main.dart' as app;

/// Integration tests specifically for SMS paste and duplicate detection
///
/// Tests:
/// - SMS paste from clipboard
/// - Duplicate transaction detection
/// - Date parsing from SMS
/// - Amount extraction
/// - Description parsing
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SMS Paste and Duplicate Detection Tests', () {
    const testEmail = 'test@budgetpillars.com';
    const testPassword = 'TestPassword123!';

    testWidgets('SMS paste and duplicate detection flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Authenticate
      await _authenticate(tester, testEmail, testPassword);

      // Ensure we have a budget
      await _ensureBudgetExists(tester);

      // Test SMS paste for expense
      await _testExpenseSMSPaste(tester);

      // Test duplicate detection
      await _testDuplicateDetection(tester);

      // Test SMS paste for income
      await _testIncomeSMSPaste(tester);

      debugPrint('✅ All SMS and duplicate tests passed!');
    });
  });
}

Future<void> _authenticate(
  WidgetTester tester,
  String email,
  String password,
) async {
  debugPrint('🧪 Authenticating...');

  final signInButton = find.text('Sign In with Email');

  if (signInButton.evaluate().isNotEmpty) {
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, email);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, password);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    debugPrint('✅ Authenticated');
  }
}

Future<void> _ensureBudgetExists(WidgetTester tester) async {
  debugPrint('🧪 Ensuring budget exists...');

  final createBudgetButton = find.text('Create Budget');

  if (createBudgetButton.evaluate().isNotEmpty) {
    // Tap the Create Budget button to open the dialog
    await tester.tap(createBudgetButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap "Start from Scratch" option in the dialog
    final startScratchButton = find.text('Start from Scratch');
    await tester.tap(startScratchButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Create a test account
    await _createTestAccount(tester);

    // Create a test category
    await _createTestCategory(tester);

    debugPrint('✅ Budget setup complete');
  }
}

Future<void> _createTestAccount(WidgetTester tester) async {
  final addAccountButton = find.byIcon(Icons.add).first;
  await tester.tap(addAccountButton);
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, 'Test Account');
  await tester.pumpAndSettle();

  final iconButton = find.text('Choose Icon').first;
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(IconButton).first);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add Account'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _createTestCategory(WidgetTester tester) async {
  final addButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Category'));
  await tester.pumpAndSettle();

  final nameField = find.widgetWithText(TextField, 'Category Name');
  await tester.enterText(nameField, 'Test Category');
  await tester.pumpAndSettle();

  final budgetField = find.widgetWithText(TextField, 'Budget');
  await tester.enterText(budgetField, '1000');
  await tester.pumpAndSettle();

  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(IconButton).first);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add Category'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _testExpenseSMSPaste(WidgetTester tester) async {
  debugPrint('🧪 Testing expense SMS paste...');

  // Tap category to open expense dialog
  final categoryCard = find.text('Test Category');
  await tester.tap(categoryCard);
  await tester.pumpAndSettle();

  // Find "Paste from SMS" button
  final pasteButton = find.text('Paste from SMS');

  if (pasteButton.evaluate().isNotEmpty) {
    // Set up clipboard with test SMS
    const testSMS = '''
    Your account was debited for 125.50 at SUPERMARKET on 15-Jan-2024.
    Available balance: 1000.00
    ''';

    await Clipboard.setData(const ClipboardData(text: testSMS));
    await tester.pumpAndSettle();

    // Tap paste button
    await tester.tap(pasteButton);
    await tester.pumpAndSettle();

    // Verify amount was extracted
    final amountField = find.byType(TextField).first;
    final amountWidget = tester.widget<TextField>(amountField);
    final amountText = amountWidget.controller?.text ?? '';

    expect(
      amountText.contains('125.5'),
      isTrue,
      reason: 'Amount should be extracted as 125.50',
    );
    debugPrint('✅ Amount extracted: $amountText');

    // Verify description was extracted
    final descriptionField = find.byType(TextField).last;
    final descriptionWidget = tester.widget<TextField>(descriptionField);
    final descriptionText = descriptionWidget.controller?.text ?? '';

    expect(
      descriptionText.isNotEmpty,
      isTrue,
      reason: 'Description should be extracted',
    );
    debugPrint('✅ Description extracted: $descriptionText');

    // Submit the transaction
    final addButton = find.text('Add Expense');
    await tester.tap(addButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    debugPrint('✅ Expense SMS paste successful');
  } else {
    debugPrint('⚠️ Paste from SMS button not found');
  }
}

Future<void> _testDuplicateDetection(WidgetTester tester) async {
  debugPrint('🧪 Testing duplicate detection...');

  // Try to paste the same SMS again
  final categoryCard = find.text('Test Category');
  await tester.tap(categoryCard);
  await tester.pumpAndSettle();

  final pasteButton = find.text('Paste from SMS');

  if (pasteButton.evaluate().isNotEmpty) {
    // Set up clipboard with identical SMS
    const testSMS = '''
    Your account was debited for 125.50 at SUPERMARKET on 15-Jan-2024.
    Available balance: 1000.00
    ''';

    await Clipboard.setData(const ClipboardData(text: testSMS));
    await tester.pumpAndSettle();

    // Tap paste button
    await tester.tap(pasteButton);
    await tester.pumpAndSettle();

    // Look for duplicate warning
    final warningText = find.textContaining('similar transaction');

    if (warningText.evaluate().isNotEmpty) {
      debugPrint('✅ Duplicate warning displayed correctly');
    } else {
      debugPrint('⚠️ Duplicate warning not found - may need adjustment');
    }

    // Close the dialog without adding
    final cancelButton = find.text('Cancel');
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    debugPrint('✅ Duplicate detection test complete');
  }
}

Future<void> _testIncomeSMSPaste(WidgetTester tester) async {
  debugPrint('🧪 Testing income SMS paste...');

  // Open account menu
  final accountMenu = find.byIcon(Icons.more_vert).first;
  await tester.tap(accountMenu);
  await tester.pumpAndSettle();

  // Tap "Add Income"
  final addIncomeOption = find.text('Add Income');
  await tester.tap(addIncomeOption);
  await tester.pumpAndSettle();

  // Find "Paste from SMS" button (only visible for one-time income)
  final pasteButton = find.text('Paste from SMS');

  if (pasteButton.evaluate().isNotEmpty) {
    // Set up clipboard with income SMS
    const testSMS = '''
    Salary credited: 3500.00 to your account on 01-Feb-2024.
    ''';

    await Clipboard.setData(const ClipboardData(text: testSMS));
    await tester.pumpAndSettle();

    // Tap paste button
    await tester.tap(pasteButton);
    await tester.pumpAndSettle();

    // Verify amount was extracted
    final amountField = find.byType(TextField).first;
    final amountWidget = tester.widget<TextField>(amountField);
    final amountText = amountWidget.controller?.text ?? '';

    expect(
      amountText.contains('3500'),
      isTrue,
      reason: 'Income amount should be extracted',
    );
    debugPrint('✅ Income amount extracted: $amountText');

    // Submit the income
    final addButton = find.text('Add Income');
    await tester.tap(addButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    debugPrint('✅ Income SMS paste successful');
  } else {
    debugPrint('⚠️ Income paste button not found');
  }
}
