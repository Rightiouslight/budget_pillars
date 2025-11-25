import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/card.dart' as models;
import '../dashboard_controller.dart';

/// Dialog for transferring funds between pockets
class TransferFundsDialog extends ConsumerStatefulWidget {
  final String accountId;
  final List<models.Card> cards;

  const TransferFundsDialog({
    super.key,
    required this.accountId,
    required this.cards,
  });

  @override
  ConsumerState<TransferFundsDialog> createState() =>
      _TransferFundsDialogState();
}

class _TransferFundsDialogState extends ConsumerState<TransferFundsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  String? _sourcePocketId;
  String? _destinationPocketId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<models.Card> get _pockets {
    return widget.cards.where((card) {
      return card.when(
        pocket: (_, __, ___, ____, _____) => true,
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
    }).toList();
  }

  double _getPocketBalance(String pocketId) {
    final pocket = _pockets.firstWhere(
      (card) => card.when(
        pocket: (id, _, __, ___, ____) => id == pocketId,
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
      ),
    );
    return pocket.when(
      pocket: (_, __, ___, balance, ____) => balance,
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
          ) => 0.0,
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_sourcePocketId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a source pocket')),
        );
        return;
      }

      if (_destinationPocketId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a destination pocket')),
        );
        return;
      }

      if (_sourcePocketId == _destinationPocketId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Source and destination must be different'),
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final sourceBalance = _getPocketBalance(_sourcePocketId!);

      if (amount > sourceBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient funds in source pocket (\$${sourceBalance.toStringAsFixed(2)} available)',
            ),
          ),
        );
        return;
      }

      final description = _descriptionController.text.trim();

      await ref
          .read(dashboardControllerProvider.notifier)
          .transferFunds(
            sourceAccountId: widget.accountId,
            sourceCardId: _sourcePocketId!,
            isSourcePocket: true, // Always transferring from pocket to pocket
            destinationAccountId: widget.accountId,
            destinationPocketId: _destinationPocketId!,
            amount: amount,
            description: description.isEmpty ? 'Transfer' : description,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);

    return AlertDialog(
      title: const Text('Transfer Funds'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Savings for vacation',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Source Pocket Selector
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'From Pocket',
                  border: const OutlineInputBorder(),
                  helperText: _sourcePocketId != null
                      ? 'Balance: \$${_getPocketBalance(_sourcePocketId!).toStringAsFixed(2)}'
                      : null,
                ),
                value: _sourcePocketId,
                items: _pockets
                    .map((card) {
                      return card.when(
                        pocket: (id, name, icon, balance, color) {
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Row(
                              children: [
                                Text(icon),
                                const SizedBox(width: 8),
                                Expanded(child: Text(name)),
                                Text(
                                  '\$${balance.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
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
                            ) {
                              return null;
                            },
                      );
                    })
                    .whereType<DropdownMenuItem<String>>()
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _sourcePocketId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a source pocket';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Destination Pocket Selector
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'To Pocket',
                  border: const OutlineInputBorder(),
                  helperText: _destinationPocketId != null
                      ? 'Balance: \$${_getPocketBalance(_destinationPocketId!).toStringAsFixed(2)}'
                      : null,
                ),
                value: _destinationPocketId,
                items: _pockets
                    .map((card) {
                      return card.when(
                        pocket: (id, name, icon, balance, color) {
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Row(
                              children: [
                                Text(icon),
                                const SizedBox(width: 8),
                                Expanded(child: Text(name)),
                                Text(
                                  '\$${balance.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
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
                            ) {
                              return null;
                            },
                      );
                    })
                    .whereType<DropdownMenuItem<String>>()
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _destinationPocketId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a destination pocket';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: controllerState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: controllerState.isLoading ? null : _submit,
          child: controllerState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Transfer'),
        ),
      ],
    );
  }
}
