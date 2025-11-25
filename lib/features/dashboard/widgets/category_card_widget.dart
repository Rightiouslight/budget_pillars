import 'package:flutter/material.dart';
import '../dialogs/add_category_dialog.dart';

class CategoryCardWidget extends StatelessWidget {
  final String accountId;
  final String id;
  final String name;
  final String icon;
  final double budgetValue;
  final double currentValue;
  final String? color;
  final bool isRecurring;
  final int? dueDate;

  const CategoryCardWidget({
    super.key,
    required this.accountId,
    required this.id,
    required this.name,
    required this.icon,
    required this.budgetValue,
    required this.currentValue,
    this.color,
    this.isRecurring = false,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color != null ? _parseColor(color!) : null;
    final remaining = budgetValue - currentValue;
    final progress = budgetValue > 0
        ? (currentValue / budgetValue).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = currentValue > budgetValue;

    return Card(
      color: cardColor,
      elevation: 2,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(
              accountId: accountId,
              categoryId: id,
              initialName: name,
              initialIcon: icon,
              initialBudgetValue: budgetValue,
              initialColor: color,
              initialIsRecurring: isRecurring,
              initialDueDate: dueDate,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isRecurring) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (dueDate != null) ...[
                              Text(
                                ' • Due: Day $dueDate',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Remaining Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${remaining.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        isOverBudget ? 'Over' : 'Left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Budget Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: \$${currentValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Budget: \$${budgetValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
