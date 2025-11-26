import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/user_settings_controller.dart';
import '../../data/models/currency.dart';
import '../../data/models/theme.dart' as app_theme;
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _selectedMonthStartDate;
  bool _isCompactView = false;
  Currency? _selectedCurrency;
  app_theme.Theme? _selectedTheme;

  @override
  void initState() {
    super.initState();
    // Load current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(userSettingsProvider).value;
      if (settings != null) {
        setState(() {
          _selectedMonthStartDate = settings.monthStartDate;
          _isCompactView = settings.isCompactView;
          _selectedCurrency = settings.currency;
          _selectedTheme = settings.theme;
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    final currentSettings = ref.read(userSettingsProvider).value;
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      monthStartDate: _selectedMonthStartDate ?? 1,
      isCompactView: _isCompactView,
      currency: _selectedCurrency,
      theme: _selectedTheme,
    );

    await ref
        .read(userSettingsControllerProvider.notifier)
        .updateSettings(updatedSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget Period Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Period',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set the day your budget period starts each month',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Month Start Date',
                            border: OutlineInputBorder(),
                            helperText: 'Your budget period starts on this day',
                          ),
                          value:
                              _selectedMonthStartDate ??
                              settings.monthStartDate,
                          items: List.generate(28, (index) => index + 1)
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text('Day $day'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonthStartDate = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Currency Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currency',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your preferred currency',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(),
                          ),
                          value: (_selectedCurrency ?? settings.currency)?.code,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Default (USD)'),
                            ),
                            ...[
                              'USD',
                              'EUR',
                              'GBP',
                              'JPY',
                              'CAD',
                              'AUD',
                              'ZAR',
                            ].map(
                              (code) => DropdownMenuItem(
                                value: code,
                                child: Text(code),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrency = value != null
                                  ? Currency(
                                      code: value,
                                      symbol: _getCurrencySymbol(value),
                                    )
                                  : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Display',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Compact View'),
                          subtitle: const Text(
                            'Show cards in a more condensed layout',
                          ),
                          value: _isCompactView,
                          onChanged: (value) {
                            setState(() {
                              _isCompactView = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Theme'),
                          subtitle: Text(
                            (_selectedTheme ?? settings.theme)?.mode ??
                                'system',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            _showThemeSelector(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Management',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.import_export),
                          title: const Text('Import / Export'),
                          subtitle: const Text(
                            'Backup and restore your budget data',
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            context.push('/import-export');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sign Out'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Sign Out'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && mounted) {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signOut();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading settings: $error')),
      ),
    );
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
      default:
        return '\$';
    }
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['system', 'light', 'dark'].map((mode) {
              final theme = app_theme.Theme(
                mode: mode,
                primaryColor: mode == 'dark' ? '#BB86FC' : '#1976D2',
                accentColor: mode == 'dark' ? '#03DAC6' : '#DC004E',
              );
              return RadioListTile<app_theme.Theme>(
                title: Text(
                  mode.substring(0, 1).toUpperCase() + mode.substring(1),
                ),
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
