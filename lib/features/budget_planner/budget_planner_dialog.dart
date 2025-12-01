import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/account.dart';
import '../../data/models/monthly_budget.dart';
import 'models/planner_category.dart';
import '../../core/constants/app_icons.dart';

/// Dialog for planning/adjusting category budgets for an account
class BudgetPlannerDialog extends ConsumerStatefulWidget {
  final Account account;
  final MonthlyBudget budget;
  final Function(List<PlannerCategory>) onSubmit;

  const BudgetPlannerDialog({
    super.key,
    required this.account,
    required this.budget,
    required this.onSubmit,
  });

  @override
  ConsumerState<BudgetPlannerDialog> createState() =>
      _BudgetPlannerDialogState();
}

class _BudgetPlannerDialogState extends ConsumerState<BudgetPlannerDialog> {
  final _formKey = GlobalKey<FormState>();
  late List<PlannerCategory> _categories;
  late Map<String, TextEditingController> _controllers;
  bool _showConfirmDialog = false;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  void _initializeCategories() {
    _categories = widget.account.cards
        .map(
          (card) => card.whenOrNull(
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
                  return PlannerCategory(
                    id: id,
                    name: name,
                    icon: icon,
                    accountId: widget.account.id,
                    originalValue: budgetValue,
                    budgetValue: budgetValue,
                  );
                },
          ),
        )
        .whereType<PlannerCategory>()
        .toList();

    _controllers = {};
    for (var category in _categories) {
      _controllers[category.id] = TextEditingController(
        text: category.budgetValue.toStringAsFixed(2),
      );
      _controllers[category.id]!.addListener(
        () => _updateCategory(category.id),
      );
    }
  }

  void _updateCategory(String categoryId) {
    final controller = _controllers[categoryId];
    if (controller == null) return;

    final value = double.tryParse(controller.text) ?? 0.0;
    setState(() {
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(budgetValue: value);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Calculate total income for the account
  double get _totalIncome {
    // 1. Sum up all income transactions for this account
    final incomeFromTransactions = widget.budget.transactions.fold<double>(
      0.0,
      (sum, tx) {
        if (tx.accountId == widget.account.id &&
            tx.categoryName.startsWith('Income to')) {
          return sum + tx.amount;
        }
        return sum;
      },
    );

    // 2. Sum up all UNPROCESSED recurring incomes for this account
    final incomeFromPendingRecurring = widget.budget.recurringIncomes
        .fold<double>(0.0, (sum, income) {
          final isProcessed =
              widget.budget.processedRecurringIncomes[income.id] ?? false;
          if (income.accountId == widget.account.id && !isProcessed) {
            return sum + income.amount;
          }
          return sum;
        });

    return incomeFromTransactions + incomeFromPendingRecurring;
  }

  /// Calculate total budgeted across all categories
  double get _totalBudgeted {
    return _categories.fold<double>(0.0, (sum, cat) => sum + cat.budgetValue);
  }

  /// Calculate remaining (income - budgeted)
  double get _remaining => _totalIncome - _totalBudgeted;

  /// Get list of categories that have changed
  List<PlannerCategory> get _changedCategories {
    return _categories
        .where((cat) => cat.budgetValue != cat.originalValue)
        .toList();
  }

  /// Check if form has changes
  bool get _hasChanges => _changedCategories.isNotEmpty;

  void _handleSave() {
    if (_formKey.currentState!.validate() && _hasChanges) {
      setState(() => _showConfirmDialog = true);
    }
  }

  void _handleConfirm() {
    widget.onSubmit(_changedCategories);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
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
                    'Budget Planner for ${widget.account.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get a high-level overview of your income vs. expenses and adjust your budget for this account.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),

            // Summary Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Income', _totalIncome, null),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Budgeted', _totalBudgeted, null),
                      const SizedBox(height: 8),
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Remaining',
                        _remaining,
                        _remaining >= 0 ? Colors.green : Colors.red,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories List
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryItem(category);
                  },
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _hasChanges ? _handleSave : null,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),

            // Confirmation Dialog
            if (_showConfirmDialog) _buildConfirmationDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    Color? color, {
    bool bold = false,
  }) {
    final textColor = color ?? Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor?.withOpacity(0.7),
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(PlannerCategory category) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getValidIcon(category.icon),
              size: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _controllers[category.id],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Invalid';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm Budget Changes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This will update the budget for ${_changedCategories.length} '
                    'categor${_changedCategories.length == 1 ? 'y' : 'ies'}. Are you sure?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            setState(() => _showConfirmDialog = false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _handleConfirm,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getValidIcon(String icon) {
    final codePoint = int.tryParse(icon);
    if (codePoint != null && AppIcons.isValidCategoryIcon(codePoint)) {
      return AppIcons.getCategoryIconData(codePoint);
    }
    return AppIcons.defaultCategoryIcon.iconData;
  }
}
