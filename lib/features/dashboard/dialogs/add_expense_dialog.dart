import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/card.dart' as models;
import '../../../providers/user_settings_provider.dart';
import '../../../providers/active_budget_provider.dart';
import '../../../utils/sms_parser.dart';
import '../dashboard_controller.dart';

/// Dialog for adding an expense transaction
class AddExpenseDialog extends ConsumerStatefulWidget {
  final String accountId;
  final String categoryId; // The card ID that was clicked
  final models.Card card; // The actual card for budget info and display

  const AddExpenseDialog({
    super.key,
    required this.accountId,
    required this.categoryId,
    required this.card,
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();
  bool _isDuplicate = false;
  bool _isPastedDuplicate = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // Focus on amount after dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      });
    });

    // Listen for changes to check for duplicates
    _amountController.addListener(_checkForDuplicates);
  }

  @override
  void dispose() {
    _amountController.removeListener(_checkForDuplicates);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkForDuplicates() {
    // TODO: Implement duplicate detection when transaction history is available
    // For now, we'll leave this as a placeholder
    // The TypeScript version checks if there's a transaction with the same amount and date
    setState(() {
      _isDuplicate = false;
    });
  }

  // Get budget info for the selected category
  ({double budgetValue, double currentValue})? get _categoryBudgetInfo {
    return widget.card.when(
      pocket: (_, __, ___, ____, _____) => null,
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
            return (budgetValue: budgetValue, currentValue: currentValue);
          },
    );
  }

  void _handleSetMaxAmount() {
    final budgetInfo = _categoryBudgetInfo;
    if (budgetInfo != null) {
      final remaining = budgetInfo.budgetValue - budgetInfo.currentValue;
      final maxAmount = remaining > 0 ? remaining : 0;
      _amountController.text = maxAmount.toStringAsFixed(2);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _checkForDuplicates();
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final settings = ref.read(userSettingsProvider).value;
    if (settings == null) return;

    // Find an SMS profile with parsing rules
    final smsProfile = settings.importProfiles.firstWhere(
      (profile) =>
          profile.smsStartWords.isNotEmpty || profile.smsStopWords.isNotEmpty,
      orElse: () => settings.importProfiles.isNotEmpty
          ? settings.importProfiles.first
          : throw Exception('No import profile found'),
    );

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Get currency from settings
      final currencyCode = settings.currency?.code ?? 'USD';

      // Parse the SMS data
      final smsData = SmsParser.extractSMSData(
        message: clipboardData.text!,
        currencyString: currencyCode,
        startKeywordsString: smsProfile.smsStartWords,
        stopKeywordsString: smsProfile.smsStopWords,
      );

      // Parse amount
      final amount = double.tryParse(smsData.amount);
      if (amount == null || amount == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not extract amount from clipboard text'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Parse date
      DateTime? parsedDate;
      if (smsData.date != 'N/A') {
        try {
          // Try different date formats
          final formats = [
            'dd-MMM-yyyy',
            'yyyy-MM-dd',
            'MM/dd/yyyy',
            'dd/MM/yyyy',
          ];

          for (final format in formats) {
            try {
              parsedDate = DateFormat(format).parse(smsData.date);
              break;
            } catch (_) {
              continue;
            }
          }
        } catch (_) {
          parsedDate = null;
        }
      }

      // Check for duplicate transactions
      final budgetAsync = ref.read(activeBudgetProvider);
      bool isDuplicate = false;

      print('🔍 Checking for duplicates...');
      print('   Budget hasValue: ${budgetAsync.hasValue}');
      print('   Budget value is null: ${budgetAsync.value == null}');

      if (budgetAsync.hasValue && budgetAsync.value != null) {
        final transactions = budgetAsync.value!.transactions;
        final dateToCheck = parsedDate ?? DateTime.now();

        print('   Total transactions: ${transactions.length}');
        print('   Checking amount: $amount');
        print(
          '   Checking date: ${dateToCheck.year}-${dateToCheck.month}-${dateToCheck.day}',
        );

        isDuplicate = transactions.any((tx) {
          // Check if same date (ignoring time)
          final txDate = tx.date;
          final sameDate =
              txDate.year == dateToCheck.year &&
              txDate.month == dateToCheck.month &&
              txDate.day == dateToCheck.day;

          // Check if same amount
          final sameAmount = (tx.amount - amount).abs() < 0.01;

          if (sameDate || sameAmount) {
            print(
              '   Comparing with tx: ${tx.description} - ${tx.amount} on ${txDate.year}-${txDate.month}-${txDate.day}',
            );
            print('      Same date: $sameDate, Same amount: $sameAmount');
          }

          return sameDate && sameAmount;
        });

        print('   Duplicate found: $isDuplicate');
      }

      // Populate the fields
      setState(() {
        _amountController.text = amount.toStringAsFixed(2);
        if (smsData.description != 'N/A' && smsData.description.isNotEmpty) {
          _descriptionController.text = smsData.description;
        }
        if (parsedDate != null) {
          _selectedDate = parsedDate;
        }
        _isPastedDuplicate = isDuplicate;
      });

      if (mounted) {
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Transaction data loaded - Warning: Similar transaction already exists',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction data loaded from clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing SMS: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      await ref
          .read(dashboardControllerProvider.notifier)
          .addExpense(
            accountId: widget.accountId,
            categoryId: widget.categoryId,
            amount: amount,
            description: description.isEmpty ? 'Expense' : description,
            date: _selectedDate,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);
    final categoryName = widget.card.when(
      pocket: (_, name, __, ___, ____) => name,
      category:
          (
            _,
            name,
            __,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
          ) => name,
    );

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
                    'Add Transaction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log a new expense for the "$categoryName" category.',
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
                      // Amount field with Max button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          if (_categoryBudgetInfo != null)
                            TextButton(
                              onPressed: _handleSetMaxAmount,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Max',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                          helperText: _isDuplicate
                              ? 'Warning: Duplicate detected'
                              : null,
                          helperStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.8),
                          ),
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

                      // Date picker
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
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
                          hintText: 'e.g., Weekly grocery run',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),

                      // Paste from SMS button
                      OutlinedButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste, size: 18),
                        label: const Text('Paste from SMS'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),

                      // Duplicate warning message (inline)
                      if (_isPastedDuplicate) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Possible duplicate: A transaction with the same amount and date already exists.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                        : const Text('Add Expense'),
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
