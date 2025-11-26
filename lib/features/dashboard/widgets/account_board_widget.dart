import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/account.dart';
import '../dialogs/add_pocket_dialog.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/add_expense_dialog.dart';
import '../dialogs/transfer_funds_dialog.dart';
import '../dashboard_controller.dart';
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
    double totalBudgeted = 0;

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
              totalBudgeted += budgetValue;
            },
      );
    }

    final availableToBudget = totalInPockets - totalBudgeted;

    return Stack(
      children: [
        Column(
          children: [
            // Account Header with Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account name and navigation indicator
                  Row(
                    children: [
                      Text(
                        _getValidIcon(account.icon),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'Account ${accountIndex + 1} of $totalAccounts',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Reorder buttons (only show if more than 1 account)
                      if (totalAccounts > 1) ...[
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: accountIndex > 0
                              ? () {
                                  ref
                                      .read(
                                        dashboardControllerProvider.notifier,
                                      )
                                      .reorderAccounts(
                                        oldIndex: accountIndex,
                                        newIndex: accountIndex - 1,
                                      );
                                }
                              : null,
                          tooltip: 'Move Left',
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: accountIndex < totalAccounts - 1
                              ? () {
                                  ref
                                      .read(
                                        dashboardControllerProvider.notifier,
                                      )
                                      .reorderAccounts(
                                        oldIndex: accountIndex,
                                        newIndex: accountIndex + 1,
                                      );
                                }
                              : null,
                          tooltip: 'Move Right',
                          iconSize: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'In Pockets',
                          amount: totalInPockets,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Available',
                          amount: availableToBudget,
                          color: availableToBudget >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Budgeted',
                          amount: totalBudgeted,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
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

        // Action Buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add Expense Button
              FloatingActionButton.small(
                heroTag: 'expense_${account.id}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddExpenseDialog(
                      accountId: account.id,
                      cards: account.cards,
                    ),
                  );
                },
                child: const Icon(Icons.receipt_long),
                tooltip: 'Add Expense',
              ),
              const SizedBox(height: 8),

              // Transfer Funds Button
              FloatingActionButton.small(
                heroTag: 'transfer_${account.id}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TransferFundsDialog(
                      accountId: account.id,
                      cards: account.cards,
                    ),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.swap_horiz),
                tooltip: 'Transfer Funds',
              ),
              const SizedBox(height: 8),

              // Add Category Button
              FloatingActionButton.small(
                heroTag: 'category_${account.id}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AddCategoryDialog(accountId: account.id),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: const Icon(Icons.category),
                tooltip: 'Add Category',
              ),
              const SizedBox(height: 8),

              // Add Pocket Button
              FloatingActionButton(
                heroTag: 'pocket_${account.id}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AddPocketDialog(accountId: account.id),
                  );
                },
                child: const Icon(Icons.add),
                tooltip: 'Add Pocket',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getValidIcon(String icon) {
    // Check if icon matches one of our valid account icons
    if (AppIcons.isValidAccountIcon(icon)) {
      return icon;
    }
    // Return default icon if not found
    return AppIcons.defaultAccountIcon;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
