import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/active_budget_provider.dart';
import '../../../data/models/transaction.dart' as app_models;

class ViewTransactionsDialog extends ConsumerWidget {
  const ViewTransactionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);
    final monthDisplayName = ref.watch(monthDisplayNameProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transactions - $monthDisplayName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Transactions List
            Expanded(
              child: budgetAsync.when(
                data: (budget) {
                  if (budget == null) {
                    return const Center(
                      child: Text('No budget data available'),
                    );
                  }

                  // Collect all transactions from all accounts
                  final allTransactions = <app_models.Transaction>[];
                  for (final account in budget.accounts) {
                    allTransactions.addAll(
                      budget.transactions.where(
                        (t) => t.accountId == account.id,
                      ),
                    );
                  }

                  // Sort by date descending (newest first)
                  allTransactions.sort((a, b) => b.date.compareTo(a.date));

                  if (allTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = allTransactions[index];
                      final account = budget.accounts.firstWhere(
                        (a) => a.id == transaction.accountId,
                        orElse: () => budget.accounts.first,
                      );

                      // Find the category or pocket name
                      String cardName = '';
                      IconData cardIcon = Icons.help_outline;

                      if (transaction.categoryId == 'transfer') {
                        cardName = 'Transfer';
                        cardIcon = Icons.swap_horiz;
                      } else if (transaction.categoryId == 'income') {
                        cardName = 'Income';
                        cardIcon = Icons.attach_money;
                      } else {
                        // Try to find the card (pocket or category)
                        final card = account.cards
                            .where((c) => c.id == transaction.categoryId)
                            .firstOrNull;

                        if (card != null) {
                          cardName = card.name;
                          // Determine icon based on card type
                          cardIcon = card.when(
                            pocket: (id, name, icon, balance, color) =>
                                Icons.folder,
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
                                ) => Icons.category,
                          );
                        } else {
                          cardName = transaction.categoryName;
                          cardIcon = Icons.help_outline;
                        }
                      }

                      final isTransfer = transaction.categoryId == 'transfer';
                      final isIncome = transaction.categoryId == 'income';

                      final formattedAmount = NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 2,
                      ).format(transaction.amount.abs());

                      // Determine amount color and prefix
                      Color amountColor;
                      String amountPrefix;
                      if (isTransfer) {
                        // Transfers: normal text color, no prefix
                        amountColor = Theme.of(context).colorScheme.onSurface;
                        amountPrefix = '';
                      } else if (isIncome) {
                        // Income: green with + prefix
                        amountColor = Colors.green;
                        amountPrefix = '+';
                      } else {
                        // Expenses: red with - prefix
                        amountColor = Theme.of(context).colorScheme.error;
                        amountPrefix = '-';
                      }

                      // Determine icon background color
                      Color iconBgColor;
                      Color iconColor;
                      if (isTransfer) {
                        iconBgColor = Theme.of(
                          context,
                        ).colorScheme.secondaryContainer;
                        iconColor = Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer;
                      } else if (isIncome) {
                        iconBgColor = Colors.green.withOpacity(0.2);
                        iconColor = Colors.green;
                      } else {
                        iconBgColor = Theme.of(
                          context,
                        ).colorScheme.errorContainer;
                        iconColor = Theme.of(
                          context,
                        ).colorScheme.onErrorContainer;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconBgColor,
                          child: Icon(cardIcon, color: iconColor, size: 20),
                        ),
                        title: Text(
                          transaction.description.isNotEmpty
                              ? transaction.description
                              : cardName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${account.name} • ${DateFormat.MMMd().format(transaction.date)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          '$amountPrefix$formattedAmount',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error loading transactions: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
