import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/add_expense_dialog.dart';
import '../dialogs/transfer_funds_dialog.dart';
import '../dialogs/card_details_dialog.dart';
import '../dashboard_controller.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../providers/active_budget_provider.dart';

class CategoryCardWidget extends ConsumerWidget {
  final String accountId;
  final String id;
  final String name;
  final String icon;
  final double budgetValue;
  final double currentValue;
  final String? color;
  final bool isRecurring;
  final int? dueDate;
  final List<card_model.Card> cards;

  const CategoryCardWidget({
    super.key,
    required this.accountId,
    required this.id,
    required this.name,
    required this.icon,
    required this.budgetValue,
    required this.currentValue,
    this.color,
    this.isRecurring = false,
    this.dueDate,
    required this.cards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = color != null ? _parseColor(color!) : null;
    final remaining = budgetValue - currentValue;
    final progress = budgetValue > 0
        ? (currentValue / budgetValue).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = currentValue > budgetValue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cardColor ?? Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
      child: InkWell(
        onTap: () {
          final budgetAsync = ref.read(activeBudgetProvider);
          budgetAsync.whenData((budget) {
            if (budget != null) {
              final account = budget.accounts.firstWhere(
                (acc) => acc.id == accountId,
              );
              showDialog(
                context: context,
                builder: (context) => CardDetailsDialog(
                  accountId: accountId,
                  card: card_model.Card.category(
                    id: id,
                    name: name,
                    icon: icon,
                    budgetValue: budgetValue,
                    currentValue: currentValue,
                    color: color,
                    isRecurring: isRecurring,
                    dueDate: dueDate,
                    destinationPocketId: null,
                    destinationAccountId: null,
                  ),
                  account: account,
                ),
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, name, remaining, and menu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          cardColor?.withOpacity(0.2) ??
                          Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getValidIcon(icon),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name with recurring indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isRecurring) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (dueDate != null && dueDate != 99) ...[
                              Text(
                                ' • Due: Day $dueDate',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Remaining Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${remaining.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        isOverBudget ? 'Over' : 'Left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // More menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditDialog(context);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Budget info with Quick Pay checkbox
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Budget: \$${budgetValue.toStringAsFixed(2)} | Spent: \$${currentValue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isRecurring && remaining > 0) ...[
                    Tooltip(
                      message: 'Quick Pay remaining amount',
                      child: Checkbox(
                        value: false,
                        onChanged: (checked) {
                          if (checked == true) {
                            _handleQuickPay(context, ref);
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Progress Bar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  cardColor ??
                      (isOverBudget
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary),
                ),
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showAddExpenseDialog(context),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Expense'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showTransferDialog(context),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Transfer'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // Column
      ), // InkWell
    ); // Card
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        accountId: accountId,
        categoryId: id,
        initialName: name,
        initialIcon: icon,
        initialBudgetValue: budgetValue,
        initialColor: color,
        initialIsRecurring: isRecurring,
        initialDueDate: dueDate,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        accountId: accountId,
        categoryId: id,
        card: card_model.Card.category(
          id: id,
          name: name,
          icon: icon,
          budgetValue: budgetValue,
          currentValue: currentValue,
          color: color,
          isRecurring: isRecurring,
          dueDate: dueDate,
          destinationPocketId: null,
          destinationAccountId: null,
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          TransferFundsDialog(accountId: accountId, cards: cards),
    );
  }

  Future<void> _handleQuickPay(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Pay'),
        content: Text(
          'Pay the remaining \$${(budgetValue - currentValue).toStringAsFixed(2)} for $name?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(dashboardControllerProvider.notifier)
          .quickPayCategory(accountId: accountId, categoryId: id);
    }
  }

  String _getValidIcon(String icon) {
    // Check if icon matches one of our valid category icons
    if (AppIcons.isValidCategoryIcon(icon)) {
      return icon;
    }
    // Return default icon if not found
    return AppIcons.defaultCategoryIcon;
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
