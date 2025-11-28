import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icon_picker_dialog.dart';
import '../../../core/widgets/color_picker_dialog.dart';
import '../../../providers/active_budget_provider.dart';
import '../dashboard_controller.dart';

/// Dialog for adding or editing a category
class AddCategoryDialog extends ConsumerStatefulWidget {
  final String accountId;
  final String? categoryId; // If editing, pass the category ID
  final String? initialName;
  final String? initialIcon;
  final double? initialBudgetValue;
  final String? initialColor;
  final bool? initialIsRecurring;
  final int? initialDueDate;
  final String? initialDestinationPocketId;
  final String? initialDestinationAccountId;

  const AddCategoryDialog({
    super.key,
    required this.accountId,
    this.categoryId,
    this.initialName,
    this.initialIcon,
    this.initialBudgetValue,
    this.initialColor,
    this.initialIsRecurring,
    this.initialDueDate,
    this.initialDestinationPocketId,
    this.initialDestinationAccountId,
  });

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late int _selectedIconCodePoint;
  String? _selectedColor;
  bool _isRecurring = false;
  int _dueDate = 99; // Default to 99 (None - manual only)
  String? _destinationPocketId;
  String? _destinationAccountId;

  final List<String?> _colorOptions = [
    null, // Default
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#96CEB4', // Green
    '#FFEAA7', // Yellow
    '#DFE6E9', // Gray
    '#A29BFE', // Purple
    '#FD79A8', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _budgetController = TextEditingController(
      text: widget.initialBudgetValue?.toStringAsFixed(2) ?? '',
    );

    // Parse icon from string (codePoint) or use default
    if (widget.initialIcon != null) {
      final parsed = int.tryParse(widget.initialIcon!);
      if (parsed != null && AppIcons.isValidCategoryIcon(parsed)) {
        _selectedIconCodePoint = parsed;
      } else {
        _selectedIconCodePoint = AppIcons.defaultCategoryIcon.codePoint;
      }
    } else {
      _selectedIconCodePoint = AppIcons.defaultCategoryIcon.codePoint;
    }

    _selectedColor = widget.initialColor;
    _isRecurring = widget.initialIsRecurring ?? false;
    _dueDate = widget.initialDueDate ?? 99; // Default to 99 (None)
    _destinationPocketId = widget.initialDestinationPocketId;
    _destinationAccountId = widget.initialDestinationAccountId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.categoryId != null;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final budgetValue = double.tryParse(_budgetController.text) ?? 0.0;

      // Only pass destination pocket/account if they are set (not "none")
      final destPocketId = _destinationPocketId;
      final destAccountId = _destinationAccountId;

      // Only pass dueDate if it's not 99 (manual only), otherwise pass null
      final effectiveDueDate = _dueDate == 99 ? null : _dueDate;

      if (_isEditing) {
        await ref
            .read(dashboardControllerProvider.notifier)
            .editCategory(
              accountId: widget.accountId,
              categoryId: widget.categoryId!,
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
              budgetValue: budgetValue,
              color: _selectedColor,
              isRecurring: _isRecurring,
              dueDate: effectiveDueDate,
              destinationPocketId: _isRecurring ? destPocketId : null,
              destinationAccountId: _isRecurring ? destAccountId : null,
            );
      } else {
        await ref
            .read(dashboardControllerProvider.notifier)
            .addCategory(
              accountId: widget.accountId,
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
              budgetValue: budgetValue,
              color: _selectedColor,
              isRecurring: _isRecurring,
              dueDate: effectiveDueDate,
              destinationPocketId: _isRecurring ? destPocketId : null,
              destinationAccountId: _isRecurring ? destAccountId : null,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(dashboardControllerProvider.notifier)
          .deleteCategory(
            accountId: widget.accountId,
            categoryId: widget.categoryId!,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);
    final budgetAsync = ref.watch(activeBudgetProvider);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      content: budgetAsync.when(
        data: (budget) {
          if (budget == null) {
            return const Text('No budget data available');
          }

          // Get current account and all available pockets
          final currentAccount = budget.accounts.firstWhere(
            (a) => a.id == widget.accountId,
            orElse: () => budget.accounts.first,
          );

          // Get all pockets except the default pocket of current account
          final availablePockets = <Map<String, String>>[];
          for (final account in budget.accounts) {
            for (final card in account.cards) {
              card.when(
                pocket: (id, name, icon, balance, color) {
                  // Exclude current account's default pocket
                  if (account.id == currentAccount.id &&
                      id == currentAccount.defaultPocketId) {
                    return;
                  }

                  availablePockets.add({
                    'accountId': account.id,
                    'accountName': account.name,
                    'pocketId': id,
                    'pocketName': name,
                  });
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
                      // Skip categories
                    },
              );
            }
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g., Groceries, Rent, Gas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Budget Amount
                  TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Amount',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
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
                        return 'Please enter a budget amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Icon Selector
                  const Text(
                    'Select Icon',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selected = await showDialog<int>(
                        context: context,
                        builder: (context) => IconPickerDialog(
                          availableIcons: AppIcons.categoryIcons,
                          initialCodePoint: _selectedIconCodePoint,
                          title: 'Select Category Icon',
                        ),
                      );
                      if (selected != null) {
                        setState(() {
                          _selectedIconCodePoint = selected;
                        });
                      }
                    },
                    icon: Icon(
                      AppIcons.getCategoryIconData(_selectedIconCodePoint),
                      size: 28,
                    ),
                    label: const Text('Choose Icon'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Color Selector
                  const Text(
                    'Select Color (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._colorOptions.map((color) {
                        final isSelected = color == _selectedColor;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color != null
                                  ? Color(
                                      int.parse(color.substring(1), radix: 16) +
                                          0xFF000000,
                                    )
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: color == null
                                ? Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  )
                                : null,
                          ),
                        );
                      }),
                      // Custom color picker button
                      InkWell(
                        onTap: () async {
                          // Parse current color or use default
                          Color? initialColor;
                          if (_selectedColor != null &&
                              !_colorOptions.contains(_selectedColor)) {
                            try {
                              initialColor = Color(
                                int.parse(
                                      _selectedColor!.substring(1),
                                      radix: 16,
                                    ) +
                                    0xFF000000,
                              );
                            } catch (e) {
                              initialColor = null;
                            }
                          }

                          final selectedHex = await showDialog<String>(
                            context: context,
                            builder: (context) => ColorPickerDialog(
                              initialColor: initialColor,
                              title: 'Pick Custom Color',
                            ),
                          );

                          if (selectedHex != null) {
                            setState(() {
                              _selectedColor = selectedHex;
                            });
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                _selectedColor != null &&
                                    !_colorOptions.contains(_selectedColor)
                                ? Color(
                                    int.parse(
                                          _selectedColor!.substring(1),
                                          radix: 16,
                                        ) +
                                        0xFF000000,
                                  )
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color:
                                  _selectedColor != null &&
                                      !_colorOptions.contains(_selectedColor)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width:
                                  _selectedColor != null &&
                                      !_colorOptions.contains(_selectedColor)
                                  ? 3
                                  : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.colorize,
                            size: 20,
                            color:
                                _selectedColor != null &&
                                    !_colorOptions.contains(_selectedColor)
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recurring Checkbox
                  CheckboxListTile(
                    title: const Text('Recurring Expense'),
                    subtitle: const Text('Bills that repeat every month'),
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value ?? false;
                        if (!_isRecurring) {
                          _dueDate = 99; // Reset to None
                          _destinationPocketId = null;
                          _destinationAccountId = null;
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Due Date and Destination Pocket (only if recurring)
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Due Day',
                        helperText:
                            'Select a day for auto-payment or leave as None for manual payment',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(),
                      ),
                      value: _dueDate,
                      items: [
                        const DropdownMenuItem(
                          value: 99,
                          child: Text('None (manual only)'),
                        ),
                        ...List.generate(28, (index) => index + 1).map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text('$day')),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _dueDate = value ?? 99;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Linked Pocket for Auto-Payments',
                        helperText:
                            'Optional. Auto-pay will transfer funds to this pocket',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(),
                      ),
                      value:
                          _destinationPocketId != null &&
                              _destinationAccountId != null
                          ? '${_destinationAccountId}:${_destinationPocketId}'
                          : 'none',
                      items: [
                        const DropdownMenuItem(
                          value: 'none',
                          child: Text('None (Pay from default pocket)'),
                        ),
                        ...availablePockets.map((pocket) {
                          final key =
                              '${pocket['accountId']}:${pocket['pocketId']}';
                          return DropdownMenuItem(
                            value: key,
                            child: Text(
                              '${pocket['accountName']}: ${pocket['pocketName']}',
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == 'none' || value == null) {
                            _destinationPocketId = null;
                            _destinationAccountId = null;
                          } else {
                            final parts = value.split(':');
                            _destinationAccountId = parts[0];
                            _destinationPocketId = parts[1];
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Error loading budget: $error'),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: controllerState.isLoading ? null : _delete,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
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
              : Text(_isEditing ? 'Save' : 'Add Category'),
        ),
      ],
    );
  }
}
