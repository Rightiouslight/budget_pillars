import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late String _selectedIcon;
  String? _selectedColor;
  bool _isRecurring = false;
  int? _dueDate;

  final List<String> _iconOptions = [
    '🍔',
    '🏠',
    '⚡',
    '🚗',
    '📱',
    '🎬',
    '🏥',
    '🎓',
    '🛒',
    '💊',
    '🎮',
    '✈️',
  ];

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
    _selectedIcon = widget.initialIcon ?? '🍔';
    _selectedColor = widget.initialColor;
    _isRecurring = widget.initialIsRecurring ?? false;
    _dueDate = widget.initialDueDate;
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

      if (_isEditing) {
        await ref
            .read(dashboardControllerProvider.notifier)
            .editCategory(
              accountId: widget.accountId,
              categoryId: widget.categoryId!,
              name: _nameController.text.trim(),
              icon: _selectedIcon,
              budgetValue: budgetValue,
              color: _selectedColor,
              isRecurring: _isRecurring,
              dueDate: _dueDate,
            );
      } else {
        await ref
            .read(dashboardControllerProvider.notifier)
            .addCategory(
              accountId: widget.accountId,
              name: _nameController.text.trim(),
              icon: _selectedIcon,
              budgetValue: budgetValue,
              color: _selectedColor,
              isRecurring: _isRecurring,
              dueDate: _dueDate,
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

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      content: SingleChildScrollView(
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
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
                children: _colorOptions.map((color) {
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
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                    ),
                  );
                }).toList(),
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
                      _dueDate = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Due Date (only if recurring)
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Due Date (Day of Month)',
                    border: OutlineInputBorder(),
                  ),
                  value: _dueDate,
                  items: List.generate(28, (index) => index + 1)
                      .map(
                        (day) =>
                            DropdownMenuItem(value: day, child: Text('$day')),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _dueDate = value;
                    });
                  },
                  validator: (value) {
                    if (_isRecurring && value == null) {
                      return 'Please select a due date';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
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
