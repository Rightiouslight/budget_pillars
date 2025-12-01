import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/add_expense_dialog.dart';
import '../dialogs/card_details_dialog.dart';
import '../dashboard_controller.dart';
import '../providers/transfer_mode_provider.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../providers/active_budget_provider.dart';
import '../../../providers/user_settings_provider.dart';

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
  final String? destinationPocketId;
  final String? destinationAccountId;
  final List<card_model.Card> cards;
  final bool enableInteraction;
  final bool forceFullView;

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
    this.destinationPocketId,
    this.destinationAccountId,
    required this.cards,
    this.enableInteraction = true,
    this.forceFullView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = color != null ? _parseColor(color!) : null;
    final remaining = budgetValue - currentValue;
    final progress = budgetValue > 0
        ? (currentValue / budgetValue).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = currentValue > budgetValue;
    final transferMode = ref.watch(transferModeProvider);

    // Get view preference
    final settings = ref.watch(userSettingsProvider).value;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final viewPreference = isMobile
        ? (settings?.viewPreferences?.mobile ?? 'full')
        : (settings?.viewPreferences?.desktop ?? 'full');
    final isCompact = forceFullView ? false : viewPreference == 'compact';

    if (isCompact) {
      return _buildCompactView(
        context,
        ref,
        cardColor,
        remaining,
        progress,
        transferMode != null,
      );
    }

    return _buildFullView(
      context,
      ref,
      cardColor,
      remaining,
      progress,
      isOverBudget,
      transferMode != null,
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    Color? cardColor,
    double remaining,
    double progress,
    bool isTransferMode,
  ) {
    final isOverBudget = currentValue > budgetValue;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Larger sizes for 2-column mobile layout
    final circleSize = isMobile ? 44.0 : 36.0;
    final innerCircleSize = isMobile ? 34.0 : 28.0;
    final iconSize = isMobile ? 18.0 : 14.0;
    final buttonIconSize = isMobile ? 20.0 : 16.0;
    final textStyle = isMobile
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.labelSmall;

    return Opacity(
      opacity: isTransferMode ? 0.5 : 1.0,
      child: Card(
        elevation: 1,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: !enableInteraction
              ? null
              : () => _handleCardTap(context, ref, isTransferMode),
          onDoubleTap: !enableInteraction
              ? null
              : () => _showAddExpenseDialog(context),
          onLongPress: !enableInteraction
              ? null
              : () => _showCompactMenu(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Name
                Text(
                  name,
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),

                // Circular progress with icon
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      // Progress indicator
                      SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: isMobile ? 3.0 : 2.5,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cardColor ?? Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      // Inner white circle
                      Container(
                        width: innerCircleSize,
                        height: innerCircleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      // Icon
                      Icon(
                        _getValidIcon(icon),
                        size: iconSize,
                        color:
                            cardColor ??
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                // Remaining amount
                Text(
                  '\$${remaining.abs().toStringAsFixed(0)}',
                  style: textStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                // Action buttons row
                Row(
                  children: [
                    // Expense button
                    Expanded(
                      child: InkWell(
                        onTap: () => _showAddExpenseDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: buttonIconSize,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    // Transfer button
                    Expanded(
                      child: InkWell(
                        onTap: () => _showTransferDialog(context, ref),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.swap_horiz,
                            size: buttonIconSize,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCardTap(
    BuildContext context,
    WidgetRef ref,
    bool isTransferMode,
  ) {
    // Categories cannot be transfer destinations, show message if in transfer mode
    if (isTransferMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Categories cannot be transfer destinations. Select a pocket instead.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Normal tap - show card details dialog
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
  }

  Widget _buildFullView(
    BuildContext context,
    WidgetRef ref,
    Color? cardColor,
    double remaining,
    double progress,
    bool isOverBudget,
    bool isTransferMode,
  ) {
    return Opacity(
      // Reduce opacity when in transfer mode to show it's not a valid destination
      opacity: isTransferMode ? 0.5 : 1.0,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: cardColor ?? Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: !enableInteraction
              ? null
              : () => _handleCardTap(context, ref, isTransferMode),
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
                      child: Icon(
                        _getValidIcon(icon),
                        size: 20,
                        color:
                            cardColor ??
                            Theme.of(context).colorScheme.onSecondaryContainer,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOverBudget ? Colors.red : Colors.green,
                              ),
                        ),
                        Text(
                          isOverBudget ? 'Over' : 'Left',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
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
                        onPressed: () => _showTransferDialog(context, ref),
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
      ), // Card
    ); // Opacity
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
        initialDestinationPocketId: destinationPocketId,
        initialDestinationAccountId: destinationAccountId,
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

  void _showTransferDialog(BuildContext context, WidgetRef ref) {
    // Capture the notifier before showing the snackbar to avoid disposal issues
    final transferModeNotifier = ref.read(transferModeProvider.notifier);

    // Enter transfer mode with this category as the source (for refunds)
    transferModeNotifier.enterTransferMode(
      card_model.Card.category(
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
      accountId,
    );

    // Show a snackbar to indicate transfer mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transfer mode: Select a destination pocket'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {
            transferModeNotifier.exitTransferMode();
          },
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  void _showCompactMenu(BuildContext context, WidgetRef ref) {
    final remaining = budgetValue - currentValue;
    final canQuickPay = remaining > 0 && isRecurring;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canQuickPay)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Quick Pay'),
                subtitle: Text(
                  'Pay remaining \$${remaining.toStringAsFixed(2)}',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleQuickPay(context, ref);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Category'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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

  IconData _getValidIcon(String icon) {
    // Try to parse icon as codePoint
    final codePoint = int.tryParse(icon);
    if (codePoint != null && AppIcons.isValidCategoryIcon(codePoint)) {
      return AppIcons.getCategoryIconData(codePoint);
    }
    // Return default icon if not found
    return AppIcons.defaultCategoryIcon.iconData;
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
