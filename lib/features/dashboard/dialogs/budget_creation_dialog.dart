import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/demo_budget_data.dart';
import '../../../data/models/monthly_budget.dart';
import '../../../providers/active_budget_provider.dart';
import '../dashboard_controller.dart';

/// Dialog for creating a new monthly budget with different options
class BudgetCreationDialog extends ConsumerStatefulWidget {
  const BudgetCreationDialog({super.key});

  @override
  ConsumerState<BudgetCreationDialog> createState() =>
      _BudgetCreationDialogState();
}

class _BudgetCreationDialogState extends ConsumerState<BudgetCreationDialog> {
  bool _isLoading = false;
  MonthlyBudget? _previousBudget;

  @override
  void initState() {
    super.initState();
    _loadPreviousBudget();
  }

  Future<void> _loadPreviousBudget() async {
    try {
      final budget = await ref
          .read(dashboardControllerProvider.notifier)
          .getPreviousMonthBudget();

      if (mounted) {
        setState(() {
          _previousBudget = budget;
        });
      }
    } catch (e) {
      // Silently fail - just means no previous budget exists
    }
  }

  Future<void> _createBudget(
    BudgetCreationType type, {
    bool keepBalances = false,
  }) async {
    setState(() => _isLoading = true);

    try {
      switch (type) {
        case BudgetCreationType.importPrevious:
          if (_previousBudget == null) {
            _showError('No previous budget found');
            return;
          }
          await ref
              .read(dashboardControllerProvider.notifier)
              .importPreviousBudget(
                previousBudget: _previousBudget!,
                keepBalances: keepBalances,
              );
          break;

        case BudgetCreationType.startFromScratch:
          // Create an empty budget (user will add first account)
          await ref
              .read(dashboardControllerProvider.notifier)
              .createEmptyBudget();
          break;

        case BudgetCreationType.createDemo:
          final demoBudget = DemoBudgetData.createDemoBudget();
          await ref
              .read(dashboardControllerProvider.notifier)
              .createDemoBudget(demoBudget);
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to create budget: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() => _isLoading = false);
  }

  void _showImportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Previous Budget'),
        content: const Text(
          'Would you like to keep pocket balances from the previous month?\n\n'
          'Keep Balances: Imports all recurring income, categories, and pockets with their current balances.\n\n'
          'Start from Zero: Imports the structure but resets all pocket balances to zero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createBudget(
                BudgetCreationType.importPrevious,
                keepBalances: false,
              );
            },
            child: const Text('Start from Zero'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _createBudget(
                BudgetCreationType.importPrevious,
                keepBalances: true,
              );
            },
            child: const Text('Keep Balances'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = ref.watch(monthDisplayNameProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Budget for $monthName',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to set up your budget',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // Import Previous Month Option
                _BudgetOptionCard(
                  icon: Icons.file_copy,
                  title: 'Import Previous Month',
                  description: _previousBudget != null
                      ? 'Copy structure and optionally keep balances'
                      : 'No previous budget found',
                  enabled: _previousBudget != null,
                  onTap: _previousBudget != null ? _showImportOptions : null,
                ),
                const SizedBox(height: 16),

                // Start from Scratch Option
                _BudgetOptionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Start from Scratch',
                  description:
                      'Create an empty budget and add your own accounts',
                  enabled: true,
                  onTap: () =>
                      _createBudget(BudgetCreationType.startFromScratch),
                ),
                const SizedBox(height: 16),

                // Create Demo Budget Option
                _BudgetOptionCard(
                  icon: Icons.auto_awesome,
                  title: 'Create Demo Budget',
                  description:
                      'Start with sample accounts and categories to explore',
                  enabled: true,
                  onTap: () => _createBudget(BudgetCreationType.createDemo),
                ),
              ],

              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback? onTap;

  const _BudgetOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: enabled ? null : theme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum BudgetCreationType { importPrevious, startFromScratch, createDemo }
