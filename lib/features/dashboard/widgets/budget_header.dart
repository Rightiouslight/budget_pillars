import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/active_budget_provider.dart';
import '../../../providers/user_settings_provider.dart';
import '../../../data/firebase/auth_repository.dart';
import '../../../utils/profile_picture_cache.dart';
import '../../auth/auth_controller.dart';
import '../dialogs/add_account_dialog.dart';
import '../dialogs/view_transactions_dialog.dart';

/// Provider for reorder accounts mode state
final reorderAccountsModeProvider = StateProvider<bool>((ref) => false);

class BudgetHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const BudgetHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<BudgetHeader> createState() => _BudgetHeaderState();
}

class _BudgetHeaderState extends ConsumerState<BudgetHeader> {
  int _pickerYear = DateTime.now().year;

  String _getAvatarFallback(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showMonthPicker() {
    final budgetInfo = ref.read(activeBudgetInfoProvider);
    if (budgetInfo == null) return;

    final parts = budgetInfo.monthKey.split('-');
    final currentYear = int.parse(parts[0]);
    final currentMonth = int.parse(parts[1]);

    setState(() {
      _pickerYear = currentYear;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final months = List.generate(12, (i) => i + 1);

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setDialogState(() {
                      _pickerYear--;
                    });
                  },
                ),
                Text(_pickerYear.toString()),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setDialogState(() {
                      _pickerYear++;
                    });
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final isSelected =
                      month == currentMonth && _pickerYear == currentYear;
                  final monthName = DateFormat.MMM().format(
                    DateTime(_pickerYear, month),
                  );

                  return FilledButton(
                    onPressed: () {
                      final newMonthKey =
                          '$_pickerYear-${month.toString().padLeft(2, '0')}';
                      ref
                          .read(activeBudgetInfoProvider.notifier)
                          .changeMonth(newMonthKey);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      foregroundColor: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    child: Text(monthName),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }

  void _showViewTransactionsDialog() {
    showDialog(
      context: context,
      builder: (context) => const ViewTransactionsDialog(),
    );
  }

  void _showResetCategoriesConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Categories'),
        content: const Text(
          'Are you sure you want to reset all categories to their default budgets? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement reset categories
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset Categories - Coming Soon')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final budgetInfo = ref.watch(activeBudgetInfoProvider);
    final monthDisplayName = ref.watch(monthDisplayNameProvider);
    final isReorderingAccounts = ref.watch(reorderAccountsModeProvider);
    final budget = ref.watch(activeBudgetProvider).value;
    final hasBudget = budget != null && budget.accounts.isNotEmpty;

    if (user == null || budgetInfo == null) {
      return AppBar(title: const Text('Budget Pillars'));
    }

    final isOwnBudget = !budgetInfo.isShared;

    return AppBar(
      title: Row(
        children: [
          // Budget Logo/Switcher Dropdown
          PopupMenuButton<String>(
            tooltip: 'Switch Budget',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Switch Budget',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'own',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Text(user.displayName ?? user.email ?? 'My Budget'),
                  ],
                ),
              ),
              // TODO: Add shared budgets when collaboration is implemented
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'invitations',
                child: Row(
                  children: [
                    Icon(Icons.mail, size: 16),
                    SizedBox(width: 8),
                    Text('Invitations'),
                    // TODO: Add badge for invitation count
                  ],
                ),
              ),
              if (isOwnBudget)
                const PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 16),
                      SizedBox(width: 8),
                      Text('Share & Manage Access'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'invitations') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitations - Coming Soon')),
                );
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share Budget - Coming Soon')),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          // Budget Name
          Expanded(
            child: Text(
              isOwnBudget
                  ? 'Budget Pillars'
                  : '${user.displayName ?? "Shared Budget"}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Month Navigation (center of AppBar)
        if (!isReorderingAccounts) ...[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(activeBudgetInfoProvider.notifier).previousMonth();
            },
            tooltip: 'Previous Month',
          ),
          OutlinedButton(
            onPressed: _showMonthPicker,
            child: Text(
              monthDisplayName
                  .split(' ')
                  .map((word) {
                    if (word.length > 3) {
                      return '${word.substring(0, 3)} ${word.substring(word.length - 4)}';
                    }
                    return word;
                  })
                  .join(' '),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(activeBudgetInfoProvider.notifier).nextMonth();
            },
            tooltip: 'Next Month',
          ),
        ] else ...[
          // Reordering mode - show Done button
          FilledButton.icon(
            onPressed: () {
              ref.read(reorderAccountsModeProvider.notifier).state = false;
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Done Reordering'),
          ),
        ],
        const SizedBox(width: 8),
        // User Menu Dropdown
        PopupMenuButton<String>(
          tooltip: 'User Menu',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(userSettingsProvider).value;
                    final cachedPicture = settings?.cachedProfilePicture;
                    final imageBytes = decodeProfilePicture(cachedPicture);

                    return CircleAvatar(
                      radius: 16,
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : null,
                      child: imageBytes == null
                          ? Text(_getAvatarFallback(user.displayName))
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'transactions',
              child: const Row(
                children: [
                  Icon(Icons.history, size: 16),
                  SizedBox(width: 8),
                  Text('View Transactions'),
                ],
              ),
              onTap: () {
                // Delay to allow menu to close before showing dialog
                Future.delayed(Duration.zero, _showViewTransactionsDialog);
              },
            ),
            PopupMenuItem<String>(
              value: 'reports',
              child: const Row(
                children: [
                  Icon(Icons.bar_chart, size: 16),
                  SizedBox(width: 8),
                  Text('View Reports'),
                ],
              ),
              onTap: () {
                context.push('/reports');
              },
            ),
            PopupMenuItem<String>(
              value: 'import',
              child: const Row(
                children: [
                  Icon(Icons.upload_file, size: 16),
                  SizedBox(width: 8),
                  Text('Import Transactions'),
                ],
              ),
              onTap: () {
                context.push('/import');
              },
            ),
            PopupMenuItem<String>(
              value: 'guide',
              child: const Row(
                children: [
                  Icon(Icons.help_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Guide'),
                ],
              ),
              onTap: () {
                context.push('/guide');
              },
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: const Row(
                children: [
                  Icon(Icons.settings, size: 16),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
              onTap: () {
                context.push('/settings');
              },
            ),
            PopupMenuItem<String>(
              value: 'reorder',
              child: const Row(
                children: [
                  Icon(Icons.reorder, size: 16),
                  SizedBox(width: 8),
                  Text('Reorder Accounts'),
                ],
              ),
              onTap: () {
                ref.read(reorderAccountsModeProvider.notifier).state = true;
              },
            ),
            if (hasBudget && isOwnBudget)
              PopupMenuItem<String>(
                value: 'reset',
                child: const Row(
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 8),
                    Text('Reset Categories'),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    Duration.zero,
                    _showResetCategoriesConfirmation,
                  );
                },
              ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'signout',
              child: const Row(
                children: [
                  Icon(Icons.logout, size: 16),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Add Account Button (desktop only)
        if (MediaQuery.of(context).size.width > 600)
          FilledButton.icon(
            onPressed: _showAddAccountDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Account'),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
