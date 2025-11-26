import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/account.dart';
import '../../../data/models/card.dart';
import '../../../data/models/recurring_income.dart';
import '../../../core/constants/app_icons.dart';
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

  String _getValidIcon(String? icon) {
    // Check if icon is null or empty
    if (icon == null || icon.isEmpty) {
      return AppIcons.defaultPocketIcon;
    }
    // Check if icon matches one of our valid pocket icons
    if (AppIcons.isValidPocketIcon(icon)) {
      return icon;
    }
    // Return default icon if not found
    return AppIcons.defaultPocketIcon;
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
                                Text(
                                  _getValidIcon(pocket.icon),
                                  style: const TextStyle(fontSize: 16),
                                ),
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
