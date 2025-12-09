import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/add_pocket_dialog.dart';
import '../dialogs/add_expense_dialog.dart';
import '../dialogs/transfer_funds_dialog.dart';
import '../dialogs/card_details_dialog.dart';
import '../dashboard_controller.dart';
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
  final bool forceFullView;

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
    this.forceFullView = false,
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
    final isCompact = forceFullView ? false : viewPreference == 'compact';

    // Transfer mode states
    final isTransferActive = transferMode != null;
    final isSelf =
        isTransferActive &&
        transferMode.sourceCard.when(
          pocket: (pId, _, __, ___, ____) => pId == id,
          category:
              (
                _,
                __,
                ___,
                ____,
                _____,
                ______,
                _______,
                ________,
                _________,
                __________,
              ) => false,
        );
    final isTarget = isTransferActive && !isSelf;

    if (isCompact) {
      return _buildCompactView(
        context,
        ref,
        cardColor,
        isTransferActive,
        isSelf,
        isTarget,
      );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isVerySmall = screenWidth < 400; // For really small screens

    // Larger sizes for 2-column mobile layout
    final circleSize = isVerySmall ? 36.0 : (isMobile ? 44.0 : 36.0);
    final iconSize = isVerySmall ? 14.0 : (isMobile ? 18.0 : 14.0);
    final starSize = isVerySmall ? 13.0 : (isMobile ? 12.0 : 10.0);
    final buttonIconSize = isVerySmall ? 16.0 : (isMobile ? 20.0 : 16.0);
    final textStyle = isMobile
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.labelSmall;

    return Opacity(
      opacity: isTransferActive && !isTarget && !isSelf ? 0.5 : 1.0,
      child: Card(
        elevation: 1,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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
              : BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
        ),
        child: InkWell(
          onTap: !enableInteraction
              ? null
              : () => _handleCardTap(context, ref, isTransferActive, isSelf),
          // Double-tap and long press removed - use tap to view details, buttons for actions, long press for reordering
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  name,
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),

                // Icon circle
                Stack(
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        _getValidIcon(icon),
                        size: iconSize,
                        color:
                            cardColor ??
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // Default star indicator
                    if (isDefault)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Icon(
                          Icons.star,
                          size: starSize,
                          color: Colors.amber.shade600,
                        ),
                      ),
                  ],
                ),

                // Balance
                Text(
                  '\$${balance.toStringAsFixed(0)}',
                  style: textStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.red,
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
    bool isTransferActive,
    bool isSelf,
  ) {
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
    final isSelf =
        isTransferActive &&
        transferMode.sourceCard.when(
          pocket: (pId, _, __, ___, ____) => pId == id,
          category:
              (
                _,
                __,
                ___,
                ____,
                _____,
                ______,
                _______,
                ________,
                _________,
                __________,
              ) => false,
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
                          _showDeleteConfirmation(context, ref);
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirmation dialog

              // Attempt to delete the pocket
              await _deletePocket(context, ref);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePocket(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Call deletePocket which returns error message if there are references
    final errorMessage = await ref
        .read(dashboardControllerProvider.notifier)
        .deletePocket(accountId: accountId, pocketId: id);

    if (errorMessage != null && context.mounted) {
      // Show error dialog with list of linked items
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete Pocket'),
          content: SingleChildScrollView(child: Text(errorMessage)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Success - show snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Pocket "$name" deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
