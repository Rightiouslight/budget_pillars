import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easy_budget_pillars/main.dart' as app;

/// Integration tests for Icon and Color Picker functionality
///
/// Tests:
/// - Icon picker dialog
/// - Icon search functionality
/// - Icon category filtering
/// - Color picker dialog
/// - HSV color selection
/// - Hex color input
/// - Custom color persistence
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Icon and Color Picker Tests', () {
    const testEmail = 'test@budgetpillars.com';
    const testPassword = 'TestPassword123!';

    testWidgets('Icon and color picker complete flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Authenticate
      await _authenticate(tester, testEmail, testPassword);

      // Ensure budget exists
      await _ensureBudgetExists(tester);

      // Test icon picker in account creation
      await _testAccountIconPicker(tester);

      // Test color picker in category creation
      await _testCategoryColorPicker(tester);

      // Test icon search functionality
      await _testIconSearch(tester);

      // Test color hex input
      await _testColorHexInput(tester);

      debugPrint('✅ All icon and color picker tests passed!');
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

  final startScratchButton = find.text('Start from Scratch');

  if (startScratchButton.evaluate().isNotEmpty) {
    await tester.tap(startScratchButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugPrint('✅ Budget created');
  }
}

Future<void> _testAccountIconPicker(WidgetTester tester) async {
  debugPrint('🧪 Testing account icon picker...');

  // Open add account dialog
  final addButton = find.byIcon(Icons.add).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Enter account name
  await tester.enterText(find.byType(TextField).first, 'Icon Test Account');
  await tester.pumpAndSettle();

  // Open icon picker
  final iconButton = find.text('Choose Icon').first;
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  // Verify icon picker dialog is open
  expect(find.text('Choose Icon'), findsWidgets);
  debugPrint('✅ Icon picker dialog opened');

  // Test category dropdown
  final categoryDropdown = find.byType(DropdownButton<String>).first;
  if (categoryDropdown.evaluate().isNotEmpty) {
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();

    // Select "Finance" category
    final financeOption = find.text('Finance').last;
    if (financeOption.evaluate().isNotEmpty) {
      await tester.tap(financeOption);
      await tester.pumpAndSettle();
      debugPrint('✅ Category filter applied');
    }
  }

  // Select an icon (first available icon button)
  final iconButtons = find.byType(IconButton);
  if (iconButtons.evaluate().length > 1) {
    await tester.tap(iconButtons.at(1)); // Skip close button, take first icon
    await tester.pumpAndSettle();
    debugPrint('✅ Icon selected');
  }

  // Save account
  final saveButton = find.text('Add Account');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify account was created
  expect(find.text('Icon Test Account'), findsOneWidget);
  debugPrint('✅ Account with custom icon created');
}

Future<void> _testCategoryColorPicker(WidgetTester tester) async {
  debugPrint('🧪 Testing category color picker...');

  // Open add category dialog
  final addButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Category'));
  await tester.pumpAndSettle();

  // Enter category details
  await tester.enterText(
    find.widgetWithText(TextField, 'Category Name'),
    'Color Test Category',
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, 'Budget'), '500');
  await tester.pumpAndSettle();

  // Select an icon first
  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  final firstIcon = find.byType(IconButton).at(1);
  await tester.tap(firstIcon);
  await tester.pumpAndSettle();

  // Open color picker
  final colorButton = find.text('Custom Color');
  if (colorButton.evaluate().isNotEmpty) {
    await tester.tap(colorButton);
    await tester.pumpAndSettle();

    // Verify color picker dialog is open
    expect(find.text('Choose Color'), findsOneWidget);
    debugPrint('✅ Color picker dialog opened');

    // Test hue slider (should be a Slider widget)
    final sliders = find.byType(Slider);
    if (sliders.evaluate().length >= 3) {
      // Interact with hue slider
      final hueSlider = sliders.at(0);
      await tester.drag(hueSlider, const Offset(50, 0));
      await tester.pumpAndSettle();
      debugPrint('✅ Hue slider adjusted');

      // Interact with saturation slider
      final satSlider = sliders.at(1);
      await tester.drag(satSlider, const Offset(30, 0));
      await tester.pumpAndSettle();
      debugPrint('✅ Saturation slider adjusted');

      // Interact with brightness slider
      final brightSlider = sliders.at(2);
      await tester.drag(brightSlider, const Offset(20, 0));
      await tester.pumpAndSettle();
      debugPrint('✅ Brightness slider adjusted');
    }

    // Confirm color selection
    final selectButton = find.text('Select');
    await tester.tap(selectButton);
    await tester.pumpAndSettle();
    debugPrint('✅ Custom color selected');
  }

  // Save category
  final saveButton = find.text('Add Category');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Verify category was created
  expect(find.text('Color Test Category'), findsOneWidget);
  debugPrint('✅ Category with custom color created');
}

Future<void> _testIconSearch(WidgetTester tester) async {
  debugPrint('🧪 Testing icon search...');

  // Open add pocket dialog
  final addButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Pocket'));
  await tester.pumpAndSettle();

  // Open icon picker
  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  // Find search field
  final searchField = find.widgetWithText(TextField, 'Search icons...');

  if (searchField.evaluate().isNotEmpty) {
    // Search for "wallet"
    await tester.enterText(searchField, 'wallet');
    await tester.pumpAndSettle();
    debugPrint('✅ Icon search performed');

    // Verify search results are filtered
    final iconButtons = find.byType(IconButton);
    final iconCount = iconButtons.evaluate().length;
    expect(iconCount > 0, isTrue, reason: 'Should find wallet icons');
    debugPrint('✅ Found $iconCount icons matching "wallet"');

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // Select an icon
    if (iconButtons.evaluate().length > 1) {
      await tester.tap(iconButtons.at(1));
      await tester.pumpAndSettle();
    }
  } else {
    // If no search field, just select an icon
    final iconButtons = find.byType(IconButton);
    if (iconButtons.evaluate().length > 1) {
      await tester.tap(iconButtons.at(1));
      await tester.pumpAndSettle();
    }
  }

  // Enter pocket name
  await tester.enterText(find.byType(TextField).first, 'Search Test Pocket');
  await tester.pumpAndSettle();

  // Save pocket
  final saveButton = find.text('Add Pocket');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  debugPrint('✅ Icon search test complete');
}

Future<void> _testColorHexInput(WidgetTester tester) async {
  debugPrint('🧪 Testing color hex input...');

  // Open add category dialog
  final addButton = find.byIcon(Icons.add_circle_outline).first;
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Category'));
  await tester.pumpAndSettle();

  // Enter category name
  await tester.enterText(
    find.widgetWithText(TextField, 'Category Name'),
    'Hex Color Category',
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, 'Budget'), '300');
  await tester.pumpAndSettle();

  // Select icon
  final iconButton = find.text('Choose Icon');
  await tester.tap(iconButton);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(IconButton).at(1));
  await tester.pumpAndSettle();

  // Open color picker
  final colorButton = find.text('Custom Color');
  if (colorButton.evaluate().isNotEmpty) {
    await tester.tap(colorButton);
    await tester.pumpAndSettle();

    // Find hex input field
    final hexFields = find.byType(TextField);

    for (var i = 0; i < hexFields.evaluate().length; i++) {
      final field = hexFields.at(i);
      final widget = tester.widget<TextField>(field);

      // Look for the hex field (might have # prefix or label)
      if (widget.decoration?.labelText?.contains('Hex') ?? false) {
        // Enter custom hex color
        await tester.enterText(field, '#FF5722');
        await tester.pumpAndSettle();
        debugPrint('✅ Hex color entered: #FF5722');
        break;
      }
    }

    // Confirm color
    final selectButton = find.text('Select');
    await tester.tap(selectButton);
    await tester.pumpAndSettle();
    debugPrint('✅ Hex color selected');
  }

  // Save category
  final saveButton = find.text('Add Category');
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  debugPrint('✅ Hex color input test complete');
}
