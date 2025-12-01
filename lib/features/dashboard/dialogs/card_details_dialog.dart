import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../data/models/account.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/active_budget_provider.dart';
import '../providers/transfer_mode_provider.dart';
import '../widgets/pocket_card_widget.dart';
import '../widgets/category_card_widget.dart';
import '../dashboard_controller.dart';
import 'package:intl/intl.dart';

class CardDetailsDialog extends ConsumerWidget {
  final String accountId;
  final card_model.Card card;
  final Account account;

  const CardDetailsDialog({
    super.key,
    required this.accountId,
    required this.card,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);

    // Listen for transfer mode changes and close dialog when transfer mode is entered
    ref.listen<TransferModeState?>(transferModeProvider, (previous, next) {
      // If transfer mode was just entered (previous was null, next is not null)
      if (previous == null && next != null) {
        Navigator.of(context).pop();
      }
    });

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Card at the top (no Hero animation)
            Padding(
              padding: const EdgeInsets.all(16),
              child: card.when(
                pocket: (id, name, icon, balance, color) {
                  return PocketCardWidget(
                    accountId: accountId,
                    id: id,
                    name: name,
                    icon: icon,
                    balance: balance,
                    color: color,
                    isDefault: id == account.defaultPocketId,
                    cards: account.cards,
                    enableInteraction: false,
                    forceFullView: true,
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
                        accountId: accountId,
                        id: id,
                        name: name,
                        icon: icon,
                        budgetValue: budgetValue,
                        currentValue: currentValue,
                        color: color,
                        isRecurring: isRecurring,
                        dueDate: dueDate,
                        cards: account.cards,
                        enableInteraction: false,
                        forceFullView: true,
                      );
                    },
              ),
            ),

            const Divider(height: 1),

            // Transaction history header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.list, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Transactions list
            Expanded(
              child: budgetAsync.when(
                data: (budget) {
                  if (budget == null) {
                    return const Center(child: Text('No budget data'));
                  }

                  // Filter transactions for this card
                  final cardTransactions = budget.transactions.where((txn) {
                    // For categories: match categoryId
                    // For pockets: match sourcePocketId or targetPocketId
                    return card.when(
                      pocket: (id, _, __, ___, ____) =>
                          txn.sourcePocketId == id || txn.targetPocketId == id,
                      category:
                          (
                            id,
                            _,
                            __,
                            ___,
                            ____,
                            _____,
                            ______,
                            _______,
                            ________,
                            _________,
                          ) => txn.categoryId == id,
                    );
                  }).toList();

                  if (cardTransactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cardTransactions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final txn = cardTransactions[index];
                      return Dismissible(
                        key: Key(txn.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: Text(
                                  'Are you sure you want to delete this transaction?\n\n'
                                  '${txn.description.isNotEmpty ? txn.description : 'Transaction'}\n'
                                  '\$${txn.amount.toStringAsFixed(2)}',
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
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await ref
                              .read(dashboardControllerProvider.notifier)
                              .deleteTransaction(txn.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction deleted'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Theme.of(context).colorScheme.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _TransactionTile(transaction: txn, card: card),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final card_model.Card card;

  const _TransactionTile({required this.transaction, required this.card});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Determine if this is incoming or outgoing for this card
    final isIncoming = card.when(
      pocket: (id, _, __, ___, ____) => transaction.targetPocketId == id,
      category:
          (id, _, __, ___, ____, _____, ______, _______, ________, _________) =>
              false,
    );

    // Determine the transaction type and other party
    String transactionType;
    String? otherParty;

    if (transaction.targetPocketId != null &&
        transaction.sourcePocketId != null) {
      // Transfer
      transactionType = isIncoming ? 'Transfer In' : 'Transfer Out';
      otherParty = isIncoming
          ? 'From ${transaction.categoryName}'
          : 'To ${transaction.targetPocketName}';
    } else if (transaction.targetPocketId != null) {
      // Transfer from category to pocket (sinking fund)
      transactionType = isIncoming ? 'Sinking Fund' : 'Expense';
      otherParty = isIncoming
          ? 'From ${transaction.categoryName}'
          : transaction.categoryName;
    } else {
      // Regular expense
      transactionType = 'Expense';
      otherParty = null;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isIncoming
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncoming
              ? Colors.green
              : Theme.of(context).colorScheme.error,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description.isNotEmpty
            ? transaction.description
            : transactionType,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (otherParty != null) ...[
            const SizedBox(height: 4),
            Text(otherParty, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(transaction.date),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                timeFormat.format(transaction.date),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
      trailing: Text(
        '${isIncoming ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isIncoming
              ? Colors.green
              : Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
