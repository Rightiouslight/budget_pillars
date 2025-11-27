# 🧪 Quick Test Reference Card

## Setup (One-Time)

```powershell
# 1. Create Firebase test account
#    Email: test@budgetpillars.com
#    Password: TestPassword123!

# 2. Update credentials in test files
#    Edit: app_test.dart, duplicate_detection_test.dart, icon_color_picker_test.dart
#    Change: testEmail and testPassword

# 3. Install dependencies
flutter pub get
```

## Run Tests

```powershell
# Run all tests
flutter test integration_test/

# Run specific tests
flutter test integration_test/app_test.dart                    # Complete E2E
flutter test integration_test/duplicate_detection_test.dart    # SMS & Duplicates
flutter test integration_test/icon_color_picker_test.dart      # UI Pickers

# Run on platforms
flutter test integration_test/app_test.dart -d chrome          # Web
flutter test integration_test/app_test.dart -d windows         # Windows
flutter test integration_test/app_test.dart -d emulator-5554   # Android
flutter test integration_test/app_test.dart -d "iPhone 15 Pro" # iOS
```

## Test Coverage Checklist

### ✅ Authentication & Setup

- [x] Email/password sign in
- [x] Budget initialization
- [x] User session persistence

### ✅ Data Management

- [x] Create account
- [x] Create category with budget
- [x] Create savings pocket
- [x] Add expense transaction
- [x] Add income (one-time)

### ✅ Icon Picker Features

- [x] Open icon picker dialog
- [x] Search icons
- [x] Filter by category
- [x] Select and persist icon

### ✅ Color Picker Features

- [x] Open color picker dialog
- [x] Adjust HSV sliders
- [x] Enter hex color code
- [x] Select and persist color

### ✅ SMS Functionality

- [x] Paste SMS from clipboard
- [x] Extract amount
- [x] Extract description
- [x] Parse date (4 formats)
- [x] Detect duplicates
- [x] Show warning for duplicates

### ✅ Settings

- [x] Change theme (Light/Dark)
- [x] Update preferences
- [x] Settings persistence

## Output Indicators

```
🧪 = Test starting
✅ = Test passed
⚠️ = Warning/skip
ℹ️ = Information
```

## Common Issues

| Issue          | Quick Fix                              |
| -------------- | -------------------------------------- |
| Auth fails     | Check credentials in Firebase Console  |
| Timeout        | Add more time: `Duration(seconds: 10)` |
| Widget missing | UI changed - update test selectors     |
| SMS fails      | Check SMS format matches profile       |

## Files

```
integration_test/
├── app_test.dart                      # Complete E2E suite (500+ lines)
├── duplicate_detection_test.dart      # SMS & duplicate tests (300+ lines)
├── icon_color_picker_test.dart        # UI picker tests (400+ lines)
├── README.md                          # Getting started
├── TESTING_GUIDE.md                   # Comprehensive docs
└── SUMMARY.md                         # Implementation summary
```

## Before Pushing Code

```powershell
# 1. Run tests
flutter test integration_test/

# 2. Check for errors
flutter analyze

# 3. Format code
flutter format lib/ test/ integration_test/

# 4. Commit
git add .
git commit -m "feat: your feature description"
git push
```

## Test Workflow

```
1. Write feature code
2. Run integration tests
3. Fix any failures
4. Commit changes
5. Push to repository
```

## Documentation

- `README.md` - Quick start guide
- `TESTING_GUIDE.md` - Complete documentation
- `SUMMARY.md` - Implementation overview

## Need Help?

1. Check `TESTING_GUIDE.md`
2. Review test output errors
3. Add debug: `debugPrint('Current state: ...');`
4. Test feature manually first

---

**Quick Command**: `flutter test integration_test/app_test.dart`
