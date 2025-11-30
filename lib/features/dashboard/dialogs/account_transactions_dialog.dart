import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/account.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/active_budget_provider.dart';
import '../dashboard_controller.dart';

/// Dialog to view all transactions for a specific account
class AccountTransactionsDialog extends ConsumerWidget {
  final Account account;

  const AccountTransactionsDialog({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getValidIcon(account.icon),
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
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
                        'All Transactions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Transactions list
            Expanded(
              child: budgetAsync.when(
                data: (budget) {
                  if (budget == null) {
                    return const Center(child: Text('No budget data'));
                  }

                  // Filter transactions for this account
                  final accountTransactions = budget.transactions
                      .where((txn) => txn.accountId == account.id)
                      .toList();

                  if (accountTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: accountTransactions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final txn = accountTransactions[index];
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
                        child: _TransactionTile(transaction: txn),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),

            // Close button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getValidIcon(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.account_balance_wallet;
    }
    try {
      final codePoint = int.parse(iconString);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.account_balance_wallet;
    }
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Determine transaction type
    String transactionType;
    String? subtitle;
    bool isIncoming = false;

    if (transaction.categoryId == 'income') {
      transactionType = 'Income';
      subtitle = transaction.targetPocketName ?? '';
      isIncoming = true;
    } else if (transaction.targetPocketId != null &&
        transaction.sourcePocketId != null) {
      // Transfer between pockets
      transactionType = 'Transfer';
      subtitle =
          'From ${transaction.categoryName} → ${transaction.targetPocketName}';
      isIncoming = false;
    } else if (transaction.targetPocketId != null) {
      // Transfer from category to pocket (sinking fund)
      transactionType = 'Sinking Fund';
      subtitle =
          '${transaction.categoryName} → ${transaction.targetPocketName}';
      isIncoming = false;
    } else {
      // Regular expense
      transactionType = 'Expense';
      subtitle = transaction.categoryName;
      isIncoming = false;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
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
