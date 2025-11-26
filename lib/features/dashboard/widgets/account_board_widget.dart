import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/account.dart';
import '../dialogs/add_account_dialog.dart';
import '../dialogs/add_pocket_dialog.dart';
import '../dialogs/add_category_dialog.dart';
import '../dashboard_controller.dart';
import '../../../providers/active_budget_provider.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getValidIcon(account.icon),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Account Name
              Expanded(
                child: Text(
                  account.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Pocket
                  Tooltip(
                    message: 'Add Pocket',
                    child: IconButton(
                      icon: const Icon(Icons.folder_outlined, size: 20),
                      onPressed: () => _showAddPocketDialog(context),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // Add Category
                  Tooltip(
                    message: 'Add Category',
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddCategoryDialog(context),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // More Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'planner':
                          _showBudgetPlannerDialog(context, ref);
                          break;
                        case 'reorder':
                          // TODO: Implement reorder mode
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
                        value: 'reorder',
                        child: Row(
                          children: [
                            Icon(Icons.reorder, size: 18),
                            SizedBox(width: 12),
                            Text('Reorder Items'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary Card
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Total in Pockets',
                          amount: totalInPockets,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Current Budget',
                          amount: currentBudget,
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Funds',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Available',
                                  style: Theme.of(context).textTheme.bodySmall
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
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '\$${availableToBudget.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall
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

                const SizedBox(height: 16),

                // Cards List
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
                      : ReorderableListView.builder(
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
                                        cards: account.cards,
                                      );
                                    },
                              ),
                            );
                          },
                        ),
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

  String _getValidIcon(String icon) {
    if (AppIcons.isValidAccountIcon(icon)) {
      return icon;
    }
    return AppIcons.defaultAccountIcon;
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
