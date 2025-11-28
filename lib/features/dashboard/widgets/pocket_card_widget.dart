import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/add_pocket_dialog.dart';
import '../dialogs/add_expense_dialog.dart';
import '../dialogs/transfer_funds_dialog.dart';
import '../dialogs/card_details_dialog.dart';
import '../providers/transfer_mode_provider.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../providers/active_budget_provider.dart';
import '../../../providers/user_settings_provider.dart';

class PocketCardWidget extends ConsumerWidget {
  final String accountId;
  final String id;
  final String name;
  final String icon;
  final double balance;
  final String? color;
  final bool isDefault;
  final List<card_model.Card> cards;
  final bool enableInteraction;

  const PocketCardWidget({
    super.key,
    required this.accountId,
    required this.id,
    required this.name,
    required this.icon,
    required this.balance,
    this.color,
    this.isDefault = false,
    required this.cards,
    this.enableInteraction = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = color != null ? _parseColor(color!) : null;
    final transferMode = ref.watch(transferModeProvider);
    
    // Get view preference
    final settings = ref.watch(userSettingsProvider).value;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final viewPreference = isMobile
        ? (settings?.viewPreferences?.mobile ?? 'full')
        : (settings?.viewPreferences?.desktop ?? 'full');
    final isCompact = viewPreference == 'compact';
    
    // Transfer mode states
    final isTransferActive = transferMode != null;
    final isSelf = isTransferActive && transferMode.sourceCard.when(
      pocket: (pId, _, __, ___, ____) => pId == id,
      category: (_, __, ___, ____, _____, ______, _______, ________, _________, __________) => false,
    );
    final isTarget = isTransferActive && !isSelf;

    if (isCompact) {
      return _buildCompactView(context, ref, cardColor, isTransferActive, isSelf, isTarget);
    }
    
    return _buildFullView(context, ref, cardColor, transferMode);
  }

  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    Color? cardColor,
    bool isTransferActive,
    bool isSelf,
    bool isTarget,
  ) {
    return Opacity(
      opacity: isTransferActive && !isTarget && !isSelf ? 0.5 : 1.0,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelf
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : isTarget
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    )
                  : BorderSide.none,
        ),
        child: InkWell(
          onTap: !enableInteraction
              ? null
              : () => _handleCardTap(context, ref, isTransferActive, isSelf),
          onDoubleTap: !enableInteraction ? null : () => _showAddExpenseDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                
                // Icon circle
                Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        _getValidIcon(icon),
                        size: 14,
                        color: cardColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // Default star indicator
                    if (isDefault)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Icon(
                          Icons.star,
                          size: 10,
                          color: Colors.amber.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                
                // Balance
                Text(
                  '\$${balance.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Theme.of(context).colorScheme.onSurface : Colors.red,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Expense button
                    InkWell(
                      onTap: () => _showAddExpenseDialog(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    // Transfer button
                    InkWell(
                      onTap: () => _showTransferDialog(context, ref),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
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

  void _handleCardTap(BuildContext context, WidgetRef ref, bool isTransferActive, bool isSelf) {
    final transferMode = ref.read(transferModeProvider);
    
    // If in transfer mode and this is a valid target
    if (isTransferActive && !isSelf && transferMode != null) {
      final destinationCard = card_model.Card.pocket(
        id: id,
        name: name,
        icon: icon,
        balance: balance,
        color: color,
      );

      // Hide the snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Exit transfer mode
      ref.read(transferModeProvider.notifier).exitTransferMode();

      // Show transfer dialog with pre-selected source and destination
      showDialog(
        context: context,
        builder: (context) => TransferFundsDialog(
          sourceAccountId: transferMode.accountId,
          destinationAccountId: accountId,
          sourceCard: transferMode.sourceCard,
          destinationCard: destinationCard,
        ),
      );
      return;
    }
    
    // If transfer source is self, cancel transfer
    if (isSelf) {
      ref.read(transferModeProvider.notifier).exitTransferMode();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            card: card_model.Card.pocket(
              id: id,
              name: name,
              icon: icon,
              balance: balance,
              color: color,
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
    TransferModeState? transferMode,
  ) {
    final isTransferActive = transferMode != null;
    final isSelf = isTransferActive && transferMode.sourceCard.when(
      pocket: (pId, _, __, ___, ____) => pId == id,
      category: (_, __, ___, ____, _____, ______, _______, ________, _________, __________) => false,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: transferMode != null
              ? Theme.of(context).colorScheme.secondary
              : (cardColor ?? Theme.of(context).colorScheme.primary),
          width: 3,
        ),
      ),
      child: InkWell(
        onTap: !enableInteraction
            ? null
            : () => _handleCardTap(context, ref, isTransferActive, isSelf),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, name, balance, and menu
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
                          Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getValidIcon(icon),
                      size: 20,
                      color:
                          cardColor ??
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name with default indicator
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
                            if (isDefault) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pocket',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Balance
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
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
                      PopupMenuItem(
                        value: 'delete',
                        enabled: !isDefault,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: isDefault ? Colors.grey : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: isDefault ? Colors.grey : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
    ); // Card
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPocketDialog(
        accountId: accountId,
        pocketId: id,
        initialName: name,
        initialIcon: icon,
        initialColor: color,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    if (isDefault) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pocket'),
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
        card: card_model.Card.pocket(
          id: id,
          name: name,
          icon: icon,
          balance: balance,
          color: color,
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref) {
    // Capture the notifier before showing the snackbar to avoid disposal issues
    final transferModeNotifier = ref.read(transferModeProvider.notifier);

    // Enter transfer mode with this pocket as the source
    transferModeNotifier.enterTransferMode(
      card_model.Card.pocket(
        id: id,
        name: name,
        icon: icon,
        balance: balance,
        color: color,
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

  IconData _getValidIcon(String icon) {
    // Try to parse icon as codePoint
    final codePoint = int.tryParse(icon);
    if (codePoint != null && AppIcons.isValidPocketIcon(codePoint)) {
      return AppIcons.getPocketIconData(codePoint);
    }
    // Return default icon if not found
    return AppIcons.defaultPocketIcon.iconData;
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
