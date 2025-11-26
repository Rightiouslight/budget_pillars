import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../data/models/account.dart';
import '../widgets/pocket_card_widget.dart';
import '../widgets/category_card_widget.dart';
import 'add_expense_dialog.dart';
import 'transfer_funds_dialog.dart';

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
                      );
                    },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Get the card ID
                        final cardId = card.when(
                          pocket: (id, _, __, ___, ____) => id,
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
                              ) => id,
                        );
                        showDialog(
                          context: context,
                          builder: (context) => AddExpenseDialog(
                            accountId: accountId,
                            categoryId: cardId,
                            card: card,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add Expense'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => TransferFundsDialog(
                            accountId: accountId,
                            cards: account.cards,
                          ),
                        );
                      },
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Transfer'),
                    ),
                  ),
                ],
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

            // Transactions list - placeholder for now
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Transaction history coming soon',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
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
