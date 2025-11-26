import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/card.dart' as models;
import '../dashboard_controller.dart';

/// Dialog for transferring funds between pockets/categories
class TransferFundsDialog extends ConsumerStatefulWidget {
  final String accountId;
  final models.Card sourceCard; // Pre-selected source
  final models.Card destinationCard; // Pre-selected destination (pocket)

  const TransferFundsDialog({
    super.key,
    required this.accountId,
    required this.sourceCard,
    required this.destinationCard,
  });

  @override
  ConsumerState<TransferFundsDialog> createState() =>
      _TransferFundsDialogState();
}

class _TransferFundsDialogState extends ConsumerState<TransferFundsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

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

  // Get the source card details
  String get _sourceCardId => widget.sourceCard.when(
    pocket: (id, _, __, ___, ____) => id,
    category:
        (id, _, __, ___, ____, _____, ______, _______, ________, _________) =>
            id,
  );

  String get _sourceCardName => widget.sourceCard.when(
    pocket: (_, name, __, ___, ____) => name,
    category:
        (_, name, __, ___, ____, _____, ______, _______, ________, _________) =>
            name,
  );

  String get _sourceCardIcon => widget.sourceCard.when(
    pocket: (_, __, icon, ___, ____) => icon,
    category:
        (_, __, icon, ___, ____, _____, ______, _______, ________, _________) =>
            icon,
  );

  bool get _isSourcePocket => widget.sourceCard.when(
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

  double get _sourceAvailableAmount => widget.sourceCard.when(
    pocket: (_, __, ___, balance, ____) => balance,
    category:
        (
          _,
          __,
          ___,
          budgetValue,
          currentValue,
          ____,
          _____,
          ______,
          _______,
          ________,
        ) {
          // For categories, available is what's been spent (currentValue)
          return currentValue;
        },
  );

  // Get the destination pocket details
  String get _destinationPocketId => widget.destinationCard.when(
    pocket: (id, _, __, ___, ____) => id,
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
        ) => '',
  );

  String get _destinationPocketName => widget.destinationCard.when(
    pocket: (_, name, __, ___, ____) => name,
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
        ) => '',
  );

  String get _destinationPocketIcon => widget.destinationCard.when(
    pocket: (_, __, icon, ___, ____) => icon,
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
        ) => '',
  );

  double get _destinationBalance => widget.destinationCard.when(
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      if (amount > _sourceAvailableAmount) {
        final sourceType = _isSourcePocket ? 'pocket' : 'category';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient funds in source $sourceType (\$${_sourceAvailableAmount.toStringAsFixed(2)} available)',
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
            sourceCardId: _sourceCardId,
            isSourcePocket: _isSourcePocket,
            destinationAccountId: widget.accountId,
            destinationPocketId: _destinationPocketId,
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

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 425),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer Funds',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Move funds from $_sourceCardName to $_destinationPocketName',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source card display
                      Text(
                        'From',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _sourceCardIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sourceCardName,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              '\$${_sourceAvailableAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Destination pocket display
                      Text('To', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _destinationPocketIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _destinationPocketName,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              '\$${_destinationBalance.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                          helperText:
                              'Available: \$${_sourceAvailableAmount.toStringAsFixed(2)}',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
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
                      Text(
                        'Description (Optional)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Savings transfer',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controllerState.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
