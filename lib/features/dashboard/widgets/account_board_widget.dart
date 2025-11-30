import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../data/models/account.dart';
import '../dialogs/add_account_dialog.dart';
import '../dialogs/add_pocket_dialog.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/add_income_dialog.dart';
import '../dialogs/recurring_incomes_dialog.dart';
import '../dialogs/import_from_sms_dialog.dart';
import '../dialogs/account_transactions_dialog.dart';
import '../dashboard_controller.dart';
import '../../../providers/active_budget_provider.dart';
import '../../../providers/user_settings_provider.dart';
import '../../budget_planner/budget_planner_dialog.dart';
import 'pocket_card_widget.dart';
import 'category_card_widget.dart';
import '../../../core/constants/app_icons.dart';

class AccountBoardWidget extends ConsumerWidget {
  final Account account;
  final int accountIndex;
  final int totalAccounts;

  const AccountBoardWidget({
    super.key,
    required this.account,
    required this.accountIndex,
    required this.totalAccounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate account summary
    double totalInPockets = 0;
    double currentBudget = 0;

    for (final card in account.cards) {
      card.when(
        pocket: (id, name, icon, balance, color) {
          totalInPockets += balance;
        },
        category:
            (
              id,
              name,
              icon,
              budgetValue,
              currentValue,
              color,
              isRecurring,
              dueDate,
              destinationPocketId,
              destinationAccountId,
            ) {
              final remaining = budgetValue - currentValue;
              if (remaining > 0) {
                currentBudget += remaining;
              }
            },
      );
    }

    final totalFunds = totalInPockets;
    final availableToBudget = totalFunds - currentBudget;

    return Column(
      children: [
        // Account Header with toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              // Account Icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getValidIcon(account.icon),
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),

              // Account Name
              Expanded(
                child: Text(
                  account.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Income
                  Tooltip(
                    message: 'Add Income',
                    child: IconButton(
                      icon: const Icon(Icons.attach_money, size: 18),
                      onPressed: () => _showAddIncomeDialog(context),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),

                  // Recurring Incomes
                  Tooltip(
                    message: 'Recurring Incomes',
                    child: IconButton(
                      icon: const Icon(Icons.event_repeat, size: 18),
                      onPressed: () =>
                          _showRecurringIncomesDialog(context, ref),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),

                  // Add Pocket
                  Tooltip(
                    message: 'Add Pocket',
                    child: IconButton(
                      icon: const Icon(Icons.folder_outlined, size: 18),
                      onPressed: () => _showAddPocketDialog(context),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),

                  // Add Category
                  Tooltip(
                    message: 'Add Category',
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => _showAddCategoryDialog(context),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),

                  // More Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 18),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'view_transactions':
                          _showAccountTransactionsDialog(context);
                          break;
                        case 'planner':
                          _showBudgetPlannerDialog(context, ref);
                          break;
                        case 'export':
                          _handleExportAccountData(context, ref);
                          break;
                        case 'import':
                          _handleImportAccountData(context, ref);
                          break;
                        case 'import_sms':
                          _showImportFromSmsDialog(context);
                          break;
                        case 'edit':
                          _showEditAccountDialog(context);
                          break;
                        case 'delete':
                          _showDeleteAccountDialog(context, ref);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view_transactions',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, size: 18),
                            SizedBox(width: 12),
                            Text('View Transactions'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'planner',
                        child: Row(
                          children: [
                            Icon(Icons.calculate_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Budget Planner'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Export Data'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            Icon(Icons.upload_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Import Data'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'import_sms',
                        child: Row(
                          children: [
                            Icon(Icons.sms_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Import from SMS'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 12),
                            Text('Edit Account'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Summary Card
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Total in Pockets',
                          amount: totalInPockets,
                        ),
                        const SizedBox(height: 4),
                        _SummaryRow(
                          label: 'Current Budget',
                          amount: currentBudget,
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Funds',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Available',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${totalFunds.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '\$${availableToBudget.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: availableToBudget >= 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Cards List/Grid
                Expanded(
                  child: account.cards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No pockets or categories yet',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a pocket or category to get started',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : _buildCardsView(context, ref),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPocketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPocketDialog(accountId: account.id),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(accountId: account.id),
    );
  }

  void _showAddIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddIncomeDialog(account: account),
    );
  }

  void _showRecurringIncomesDialog(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.read(activeBudgetProvider);
    budgetAsync.whenData((budget) {
      if (budget != null) {
        showDialog(
          context: context,
          builder: (context) =>
              RecurringIncomesDialog(account: account, budget: budget),
        );
      }
    });
  }

  void _showBudgetPlannerDialog(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.read(activeBudgetProvider);
    budgetAsync.whenData((budget) {
      if (budget != null) {
        showDialog(
          context: context,
          builder: (context) => BudgetPlannerDialog(
            account: account,
            budget: budget,
            onSubmit: (changedCategories) async {
              // Convert list to map for the controller
              final categoryBudgets = <String, double>{};
              for (var category in changedCategories) {
                categoryBudgets[category.id] = category.budgetValue;
              }

              await ref
                  .read(dashboardControllerProvider.notifier)
                  .updateCategoryBudgets(
                    accountId: account.id,
                    categoryBudgets: categoryBudgets,
                  );
            },
          ),
        );
      }
    });
  }

  void _showEditAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddAccountDialog(
        accountId: account.id,
        initialName: account.name,
        initialIcon: account.icon,
      ),
    );
  }

  void _showImportFromSmsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImportFromSmsDialog(account: account),
    );
  }

  void _showAccountTransactionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AccountTransactionsDialog(account: account),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(dashboardControllerProvider.notifier)
                  .deleteAccount(account.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportAccountData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final controller = ref.read(dashboardControllerProvider.notifier);
      final jsonData = await controller.exportAccountData(account.id);

      if (jsonData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to export account data')),
          );
        }
        return;
      }

      // Ask user how they want to export
      if (!context.mounted) return;

      final exportChoice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Account Data'),
          content: const Text('How would you like to export the data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('clipboard'),
              child: const Text('Copy to Clipboard'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('file'),
              child: const Text('Save to File'),
            ),
          ],
        ),
      );

      if (exportChoice == null || !context.mounted) return;

      if (exportChoice == 'clipboard') {
        await Clipboard.setData(ClipboardData(text: jsonData));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Export data for ${account.name} copied to clipboard',
              ),
            ),
          );
        }
      } else if (exportChoice == 'file') {
        final fileName =
            'budgetpillars_export_${account.name.replaceAll(' ', '_')}.json';

        try {
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final file = File('${directory.path}/$fileName');
            await file.writeAsString(jsonData);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported ${account.name} to Downloads/$fileName',
                  ),
                ),
              );
            }
          } else {
            throw Exception('Could not access Downloads directory');
          }
        } catch (e) {
          // Fallback: Copy to clipboard if file save fails
          await Clipboard.setData(ClipboardData(text: jsonData));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not save file. Data copied to clipboard instead.',
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _handleImportAccountData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Try to pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      String? jsonData;

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          jsonData = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          final fileContent = File(file.path!);
          jsonData = await fileContent.readAsString();
        }
      } else {
        // If file picker cancelled, try clipboard as fallback
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
          // Show dialog to ask if user wants to import from clipboard
          if (context.mounted) {
            final useClipboard = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Import from Clipboard?'),
                content: const Text(
                  'No file selected. Would you like to import from clipboard?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Import'),
                  ),
                ],
              ),
            );

            if (useClipboard == true) {
              jsonData = clipboardData.text;
            }
          }
        }
      }

      if (jsonData == null || jsonData.isEmpty) {
        return;
      }

      // Ask user if they want to include balances
      if (context.mounted) {
        final includeBalances = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Pocket Balances?'),
            content: const Text(
              'Do you want to import the pocket balances from the file?\n\n'
              'Yes - Replace current balances with imported values\n'
              'No - Keep current balances and only import structure',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No (Keep Current)'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes (Import Balances)'),
              ),
            ],
          ),
        );

        if (includeBalances == null) {
          // User cancelled
          return;
        }

        // Import the data
        final controller = ref.read(dashboardControllerProvider.notifier);
        await controller.importAccountData(
          account.id,
          jsonData,
          includeBalances: includeBalances,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                includeBalances
                    ? 'Data imported successfully with balances'
                    : 'Data imported successfully (balances preserved)',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  IconData _getValidIcon(String icon) {
    // Try to parse icon as codePoint
    final codePoint = int.tryParse(icon);
    if (codePoint != null && AppIcons.isValidAccountIcon(codePoint)) {
      return AppIcons.getAccountIconData(codePoint);
    }
    // Return default icon if not found
    return AppIcons.defaultAccountIcon.iconData;
  }

  Widget _buildCardsView(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final viewPrefs = settings.viewPreferences;
        final viewPref = screenWidth < 600
            ? viewPrefs?.mobile
            : viewPrefs?.desktop;
        final isCompact = viewPref == 'compact';

        if (isCompact) {
          // 2 columns for mobile (<600), 3 columns for tablets
          final crossAxisCount = screenWidth < 600 ? 2 : 3;

          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: account.cards.length,
            itemBuilder: (context, index) {
              final card = account.cards[index];
              return card.when(
                pocket: (id, name, icon, balance, color) {
                  return PocketCardWidget(
                    accountId: account.id,
                    id: id,
                    name: name,
                    icon: icon,
                    balance: balance,
                    color: color,
                    isDefault: id == account.defaultPocketId,
                    cards: account.cards,
                  );
                },
                category:
                    (
                      id,
                      name,
                      icon,
                      budgetValue,
                      currentValue,
                      color,
                      isRecurring,
                      dueDate,
                      destinationPocketId,
                      destinationAccountId,
                    ) {
                      return CategoryCardWidget(
                        accountId: account.id,
                        id: id,
                        name: name,
                        icon: icon,
                        budgetValue: budgetValue,
                        currentValue: currentValue,
                        color: color,
                        isRecurring: isRecurring,
                        dueDate: dueDate,
                        destinationPocketId: destinationPocketId,
                        destinationAccountId: destinationAccountId,
                        cards: account.cards,
                      );
                    },
              );
            },
          );
        } else {
          return ReorderableListView.builder(
            padding: EdgeInsets.zero,
            itemCount: account.cards.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(dashboardControllerProvider.notifier)
                  .reorderCards(
                    accountIndex: accountIndex,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  );
            },
            itemBuilder: (context, index) {
              final card = account.cards[index];

              return Padding(
                key: ValueKey('card_${account.id}_$index'),
                padding: const EdgeInsets.only(bottom: 12),
                child: card.when(
                  pocket: (id, name, icon, balance, color) {
                    return PocketCardWidget(
                      accountId: account.id,
                      id: id,
                      name: name,
                      icon: icon,
                      balance: balance,
                      color: color,
                      isDefault: id == account.defaultPocketId,
                      cards: account.cards,
                    );
                  },
                  category:
                      (
                        id,
                        name,
                        icon,
                        budgetValue,
                        currentValue,
                        color,
                        isRecurring,
                        dueDate,
                        destinationPocketId,
                        destinationAccountId,
                      ) {
                        return CategoryCardWidget(
                          accountId: account.id,
                          id: id,
                          name: name,
                          icon: icon,
                          budgetValue: budgetValue,
                          currentValue: currentValue,
                          color: color,
                          isRecurring: isRecurring,
                          dueDate: dueDate,
                          destinationPocketId: destinationPocketId,
                          destinationAccountId: destinationAccountId,
                          cards: account.cards,
                        );
                      },
                ),
              );
            },
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildDefaultListView(ref),
    );
  }

  Widget _buildDefaultListView(WidgetRef ref) {
    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      itemCount: account.cards.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(dashboardControllerProvider.notifier)
            .reorderCards(
              accountIndex: accountIndex,
              oldIndex: oldIndex,
              newIndex: newIndex,
            );
      },
      itemBuilder: (context, index) {
        final card = account.cards[index];

        return Padding(
          key: ValueKey('card_${account.id}_$index'),
          padding: const EdgeInsets.only(bottom: 12),
          child: card.when(
            pocket: (id, name, icon, balance, color) {
              return PocketCardWidget(
                accountId: account.id,
                id: id,
                name: name,
                icon: icon,
                balance: balance,
                color: color,
                isDefault: id == account.defaultPocketId,
                cards: account.cards,
              );
            },
            category:
                (
                  id,
                  name,
                  icon,
                  budgetValue,
                  currentValue,
                  color,
                  isRecurring,
                  dueDate,
                  destinationPocketId,
                  destinationAccountId,
                ) {
                  return CategoryCardWidget(
                    accountId: account.id,
                    id: id,
                    name: name,
                    icon: icon,
                    budgetValue: budgetValue,
                    currentValue: currentValue,
                    color: color,
                    isRecurring: isRecurring,
                    dueDate: dueDate,
                    destinationPocketId: destinationPocketId,
                    destinationAccountId: destinationAccountId,
                    cards: account.cards,
                  );
                },
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;

  const _SummaryRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
