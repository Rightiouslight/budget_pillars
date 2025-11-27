import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/user_settings_controller.dart';
import '../../providers/active_budget_provider.dart';
import '../../data/models/currency.dart';
import '../../data/models/theme.dart' as app_theme;
import '../../data/models/view_preferences.dart';
import '../dashboard/dashboard_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _selectedMonthStartDate;
  Currency? _selectedCurrency;
  app_theme.Theme? _selectedTheme;
  ViewPreferences? _selectedViewPreferences;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(userSettingsProvider).value;
      if (settings != null) {
        setState(() {
          _selectedMonthStartDate = settings.monthStartDate;
          _selectedCurrency = settings.currency;
          _selectedTheme = settings.theme;
          _selectedViewPreferences =
              settings.viewPreferences ?? const ViewPreferences();
        });
      }
    });
  }

  Future<void> _autoSaveSettings() async {
    final currentSettings = ref.read(userSettingsProvider).value;
    if (currentSettings == null) {
      print('⚠️ Settings auto-save: No current settings available');
      return;
    }

    final updatedSettings = currentSettings.copyWith(
      monthStartDate: _selectedMonthStartDate ?? 1,
      currency: _selectedCurrency,
      theme: _selectedTheme,
      viewPreferences: _selectedViewPreferences,
    );

    print(
      '💾 Saving settings: theme=${_selectedTheme?.name}/${_selectedTheme?.appearance}, currency=${_selectedCurrency?.code}',
    );

    try {
      await ref
          .read(userSettingsControllerProvider.notifier)
          .updateSettings(updatedSettings);
      print('✅ Settings saved successfully');
    } catch (e) {
      print('❌ Error saving settings: $e');
    }
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'ZAR':
        return 'R';
      case 'NAD':
        return 'N\$';
      case 'INR':
        return '₹';
      case 'CNY':
        return '¥';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return 'MX\$';
      case 'CHF':
        return 'CHF';
      case 'NZD':
        return 'NZ\$';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      default:
        return '\$';
    }
  }

  String _getCurrencyName(String code) {
    const names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
      'ZAR': 'South African Rand',
      'NAD': 'Namibian Dollar',
      'INR': 'Indian Rupee',
      'CNY': 'Chinese Yuan',
      'BRL': 'Brazilian Real',
      'MXN': 'Mexican Peso',
      'CHF': 'Swiss Franc',
      'NZD': 'New Zealand Dollar',
      'SEK': 'Swedish Krona',
      'NOK': 'Norwegian Krone',
      'DKK': 'Danish Krone',
    };
    return names[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (settings) {
          // Initialize state from loaded settings if not already set
          _selectedMonthStartDate ??= settings.monthStartDate;
          _selectedCurrency ??= settings.currency;
          _selectedTheme ??= settings.theme;
          _selectedViewPreferences ??=
              settings.viewPreferences ?? const ViewPreferences();

          final appearance = _selectedTheme?.appearance ?? 'system';
          final themeName = _selectedTheme?.name ?? 'mint';
          final mobile = _selectedViewPreferences?.mobile ?? 'full';
          final desktop = _selectedViewPreferences?.desktop ?? 'full';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appearance Section
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAppearanceOption(
                        icon: Icons.light_mode,
                        label: 'Light',
                        value: 'light',
                        selected: appearance == 'light',
                        onTap: () {
                          setState(() {
                            _selectedTheme =
                                (_selectedTheme ?? const app_theme.Theme())
                                    .copyWith(appearance: 'light');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAppearanceOption(
                        icon: Icons.dark_mode,
                        label: 'Dark',
                        value: 'dark',
                        selected: appearance == 'dark',
                        onTap: () {
                          setState(() {
                            _selectedTheme =
                                (_selectedTheme ?? const app_theme.Theme())
                                    .copyWith(appearance: 'dark');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAppearanceOption(
                        icon: Icons.nights_stay,
                        label: 'Black',
                        value: 'black',
                        selected: appearance == 'black',
                        onTap: () {
                          setState(() {
                            _selectedTheme =
                                (_selectedTheme ?? const app_theme.Theme())
                                    .copyWith(appearance: 'black');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAppearanceOption(
                        icon: Icons.computer,
                        label: 'System',
                        value: 'system',
                        selected: appearance == 'system',
                        onTap: () {
                          setState(() {
                            _selectedTheme =
                                (_selectedTheme ?? const app_theme.Theme())
                                    .copyWith(appearance: 'system');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Theme Name Section
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Theme',
                    border: OutlineInputBorder(),
                  ),
                  value: themeName,
                  items: const [
                    DropdownMenuItem(value: 'mint', child: Text('Mint')),
                    DropdownMenuItem(value: 'oceanic', child: Text('Oceanic')),
                    DropdownMenuItem(value: 'super', child: Text('Super')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTheme =
                            (_selectedTheme ?? const app_theme.Theme())
                                .copyWith(name: value);
                      });
                      _autoSaveSettings();
                    }
                  },
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 24),

                // View Preferences Section
                Text(
                  'View Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Mobile View
                Row(
                  children: [
                    const Icon(Icons.smartphone, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Mobile View',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildViewModeOption(
                        label: 'Full View',
                        selected: mobile == 'full',
                        onTap: () {
                          setState(() {
                            _selectedViewPreferences =
                                (_selectedViewPreferences ??
                                        const ViewPreferences())
                                    .copyWith(mobile: 'full');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildViewModeOption(
                        label: 'Compact View',
                        selected: mobile == 'compact',
                        onTap: () {
                          setState(() {
                            _selectedViewPreferences =
                                (_selectedViewPreferences ??
                                        const ViewPreferences())
                                    .copyWith(mobile: 'compact');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Desktop View
                Row(
                  children: [
                    const Icon(Icons.computer, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Desktop View',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildViewModeOption(
                        label: 'Full View',
                        selected: desktop == 'full',
                        onTap: () {
                          setState(() {
                            _selectedViewPreferences =
                                (_selectedViewPreferences ??
                                        const ViewPreferences())
                                    .copyWith(desktop: 'full');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildViewModeOption(
                        label: 'Compact View',
                        selected: desktop == 'compact',
                        onTap: () {
                          setState(() {
                            _selectedViewPreferences =
                                (_selectedViewPreferences ??
                                        const ViewPreferences())
                                    .copyWith(desktop: 'compact');
                          });
                          _autoSaveSettings();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 24),

                // Currency Section
                Text(
                  'Currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCurrency?.code ?? 'USD',
                  items:
                      [
                        'USD',
                        'EUR',
                        'GBP',
                        'JPY',
                        'CAD',
                        'AUD',
                        'ZAR',
                        'NAD',
                        'INR',
                        'CNY',
                        'BRL',
                        'MXN',
                        'CHF',
                        'NZD',
                        'SEK',
                        'NOK',
                        'DKK',
                      ].map((code) {
                        final symbol = _getCurrencySymbol(code);
                        final name = _getCurrencyName(code);
                        return DropdownMenuItem(
                          value: code,
                          child: Text('$name ($symbol)'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = Currency(
                          code: value,
                          symbol: _getCurrencySymbol(value),
                        );
                      });
                      _autoSaveSettings();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Budget Start Day Section
                Text(
                  'Budget Start Day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Budget Start Day',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedMonthStartDate ?? 1,
                  items: List.generate(28, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text('Day $day'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonthStartDate = value;
                      });
                      _autoSaveSettings();
                    }
                  },
                ),
                Text(
                  'The day of the month your budget period starts.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                const Divider(),
                const SizedBox(height: 24),

                // Danger Zone Section
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Current Month Budget',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Permanently delete all data for ${ref.watch(monthDisplayNameProvider)}. '
                          'This cannot be undone.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteConfirmation(context, ref),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete This Month\'s Budget'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final monthName = ref.read(monthDisplayNameProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Delete Budget?'),
        content: Text(
          'Are you sure you want to delete all budget data for $monthName?\n\n'
          'This will permanently remove:\n'
          '• All accounts and their cards\n'
          '• All transactions\n'
          '• All recurring incomes\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final theme = Theme.of(context);
              
              navigator.pop(); // Close confirmation dialog
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await ref
                    .read(dashboardControllerProvider.notifier)
                    .deleteCurrentMonthBudget();
                
                navigator.pop(); // Close loading dialog
                
                // Show snackbar
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Budget for $monthName deleted'),
                    backgroundColor: theme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                // Small delay then close settings
                await Future.delayed(const Duration(milliseconds: 100));
                navigator.pop(); // Close settings screen
              } catch (e) {
                navigator.pop(); // Close loading dialog
                
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting budget: $e'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceOption({
    required IconData icon,
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
              fontWeight: selected ? FontWeight.w500 : null,
            ),
          ),
        ),
      ),
    );
  }
}
