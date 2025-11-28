import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/account.dart';
import '../../../data/models/card.dart';
import '../../../data/models/recurring_income.dart';
import '../../../core/constants/app_icons.dart';
import '../../../providers/user_settings_provider.dart';
import '../../../providers/active_budget_provider.dart';
import '../../../utils/sms_parser.dart';
import '../dashboard_controller.dart';

/// Dialog for adding income to a pocket (one-time or recurring)
class AddIncomeDialog extends ConsumerStatefulWidget {
  final Account account;
  final RecurringIncome? recurringIncome;

  const AddIncomeDialog({
    super.key,
    required this.account,
    this.recurringIncome,
  });

  @override
  ConsumerState<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends ConsumerState<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  String? _selectedPocketId;
  bool _isRecurring = false;
  DateTime _selectedDate = DateTime.now();
  int _dayOfMonth = 99; // 99 = Immediately
  bool _isPastedDuplicate = false;

  IconData _getValidIcon(String? icon) {
    // Check if icon is null or empty
    if (icon == null || icon.isEmpty) {
      return AppIcons.defaultPocketIcon.iconData;
    }
    // Try to parse icon as codePoint
    final codePoint = int.tryParse(icon);
    if (codePoint != null && AppIcons.isValidPocketIcon(codePoint)) {
      return AppIcons.getPocketIconData(codePoint);
    }
    // Return default icon if not found
    return AppIcons.defaultPocketIcon.iconData;
  }

  @override
  void initState() {
    super.initState();

    if (widget.recurringIncome != null) {
      // Editing existing recurring income
      final income = widget.recurringIncome!;
      _amountController = TextEditingController(
        text: income.amount.toStringAsFixed(2),
      );
      _descriptionController = TextEditingController(
        text: income.description ?? income.name ?? '',
      );
      _selectedPocketId = income.pocketId;
      _isRecurring = true;
      _dayOfMonth = income.dayOfMonth;
    } else {
      // Adding new income
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedPocketId = widget.account.defaultPocketId;
      _isRecurring = false;
      _selectedDate = DateTime.now();
      _dayOfMonth = 99;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<PocketCard> get _pockets {
    return widget.account.cards.whereType<PocketCard>().toList();
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

      print('🔍 [INCOME] Checking for duplicates...');
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
        if (parsedDate != null && !_isRecurring) {
          _selectedDate = parsedDate;
        }
        _isPastedDuplicate = isDuplicate;
      });

      if (mounted) {
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Income data loaded - Warning: Similar transaction already exists',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          // Not a duplicate - auto-submit the transaction
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Income added from clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
          await _submit();
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
    if (_formKey.currentState!.validate() && _selectedPocketId != null) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      if (_isRecurring) {
        // Save or update recurring income
        await ref
            .read(dashboardControllerProvider.notifier)
            .saveRecurringIncome(
              id: widget.recurringIncome?.id,
              accountId: widget.account.id,
              pocketId: _selectedPocketId!,
              amount: amount,
              description: description.isEmpty
                  ? 'Recurring Income'
                  : description,
              dayOfMonth: _dayOfMonth,
            );
      } else {
        // Add one-time income
        await ref
            .read(dashboardControllerProvider.notifier)
            .addIncome(
              accountId: widget.account.id,
              pocketId: _selectedPocketId!,
              amount: amount,
              description: description.isEmpty ? 'Income' : description,
              date: _selectedDate,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);
    final isEditing = widget.recurringIncome != null;

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
                    isEditing ? 'Edit Recurring Income' : 'Add Income',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditing
                        ? 'Update the details of this scheduled income.'
                        : 'Deposit funds into one of your pockets.',
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
                      // Pocket selection
                      Text(
                        'Deposit To',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPocketId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _pockets.map((pocket) {
                          return DropdownMenuItem(
                            value: pocket.id,
                            child: Row(
                              children: [
                                Icon(_getValidIcon(pocket.icon), size: 16),
                                const SizedBox(width: 8),
                                Text(pocket.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPocketId = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a pocket';
                          }
                          return null;
                        },
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
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: OutlineInputBorder(),
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

                      // Recurring toggle (only show when adding new income)
                      if (!isEditing) ...[
                        SwitchListTile(
                          title: const Text('Recurring Income'),
                          subtitle: const Text(
                            'Schedule this income to repeat monthly.',
                          ),
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() => _isRecurring = value);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Date picker (for one-time) or Day selector (for recurring)
                      if (_isRecurring) ...[
                        Text(
                          'Deposit Day',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _dayOfMonth,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperText:
                                'The day of the month this income will be deposited.',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 99,
                              child: Text('Immediately'),
                            ),
                            ...List.generate(
                              28,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1}'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _dayOfMonth = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            DateFormat('MMM d, yyyy').format(_selectedDate),
                          ),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Monthly Salary',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),

                      // Paste from SMS button (only for one-time income)
                      if (!_isRecurring)
                        OutlinedButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.content_paste, size: 18),
                          label: const Text('Paste from SMS'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),

                      // Duplicate warning message (inline)
                      if (_isPastedDuplicate && !_isRecurring) ...[
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
                        : const Text('Add Income'),
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
