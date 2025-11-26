/// Valid icons for different card types
class AppIcons {
  // Account icons
  static const List<String> accountIcons = [
    '💼',
    '🏦',
    '💰',
    '💳',
    '🏠',
    '🚗',
    '🎓',
    '🏥',
    '🛒',
    '✈️',
    '🎯',
    '⭐',
  ];

  // Pocket icons
  static const List<String> pocketIcons = [
    '💰',
    '💵',
    '💳',
    '🏦',
    '💎',
    '🪙',
    '🎯',
    '⭐',
    '🎁',
    '📌',
    '🔖',
    '✨',
  ];

  // Category icons
  static const List<String> categoryIcons = [
    '🍔',
    '🏠',
    '⚡',
    '🚗',
    '📱',
    '🎬',
    '🏥',
    '🎓',
    '🛒',
    '💊',
    '🎮',
    '✈️',
  ];

  // Default fallback icons
  static const String defaultAccountIcon = '🏦';
  static const String defaultPocketIcon = '💰';
  static const String defaultCategoryIcon = '📁';

  /// Check if icon is valid for accounts
  static bool isValidAccountIcon(String icon) {
    return accountIcons.contains(icon);
  }

  /// Check if icon is valid for pockets
  static bool isValidPocketIcon(String icon) {
    return pocketIcons.contains(icon);
  }

  /// Check if icon is valid for categories
  static bool isValidCategoryIcon(String icon) {
    return categoryIcons.contains(icon);
  }
}
