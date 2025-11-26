import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/active_budget_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);
    final monthDisplayName = ref.watch(monthDisplayNameProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Reports - $monthDisplayName')),
      body: budgetAsync.when(
        data: (budget) {
          if (budget == null || budget.accounts.isEmpty) {
            return const Center(
              child: Text('No budget data available for this month'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spending by Category Chart
                _buildSectionTitle(context, 'Spending by Category'),
                const SizedBox(height: 16),
                _buildCategoryPieChart(context, budget),
                const SizedBox(height: 32),

                // Budget vs Actual Chart
                _buildSectionTitle(context, 'Budget vs Actual'),
                const SizedBox(height: 16),
                _buildBudgetComparisonChart(context, budget),
                const SizedBox(height: 32),

                // Category Breakdown List
                _buildSectionTitle(context, 'Category Breakdown'),
                const SizedBox(height: 16),
                _buildCategoryList(context, budget),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading reports: $error')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, budget) {
    // Collect all categories with spending
    final Map<String, double> categorySpending = {};
    final Map<String, Color> categoryColors = {};
    final colorPalette = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    int colorIndex = 0;
    for (final account in budget.accounts) {
      for (final card in account.cards) {
        card.when(
          pocket: (_, __, ___, ____, _____) {},
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
                destPocketId,
                destAcctId,
              ) {
                if (currentValue > 0) {
                  categorySpending[name] =
                      (categorySpending[name] ?? 0) + currentValue;
                  if (!categoryColors.containsKey(name)) {
                    categoryColors[name] =
                        colorPalette[colorIndex % colorPalette.length];
                    colorIndex++;
                  }
                }
              },
        );
      }
    }

    if (categorySpending.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text('No spending data available'),
        ),
      );
    }

    final sections = categorySpending.entries.map((entry) {
      final total = categorySpending.values.fold(0.0, (a, b) => a + b);
      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: categoryColors[entry.key],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categorySpending.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: categoryColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetComparisonChart(BuildContext context, budget) {
    // Collect categories with budget and actual spending
    final List<String> categoryNames = [];
    final List<double> budgetValues = [];
    final List<double> actualValues = [];

    for (final account in budget.accounts) {
      for (final card in account.cards) {
        card.when(
          pocket: (_, __, ___, ____, _____) {},
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
                destPocketId,
                destAcctId,
              ) {
                if (budgetValue > 0) {
                  categoryNames.add(name);
                  budgetValues.add(budgetValue);
                  actualValues.add(currentValue);
                }
              },
        );
      }
    }

    if (categoryNames.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text('No budget data available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: budgetValues.fold(0.0, (a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final category = categoryNames[group.x.toInt()];
                        final value = rod.toY;
                        final label = rodIndex == 0 ? 'Budget' : 'Actual';
                        return BarTooltipItem(
                          '$category\n$label: \$${value.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= categoryNames.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              categoryNames[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(categoryNames.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: budgetValues[index],
                          color: Colors.blue,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: actualValues[index],
                          color: actualValues[index] > budgetValues[index]
                              ? Colors.red
                              : Colors.green,
                          width: 12,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, Colors.blue, 'Budget'),
                const SizedBox(width: 24),
                _buildLegendItem(context, Colors.green, 'Under Budget'),
                const SizedBox(width: 24),
                _buildLegendItem(context, Colors.red, 'Over Budget'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, budget) {
    final List<Map<String, dynamic>> categories = [];

    for (final account in budget.accounts) {
      for (final card in account.cards) {
        card.when(
          pocket: (_, __, ___, ____, _____) {},
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
                destPocketId,
                destAcctId,
              ) {
                categories.add({
                  'name': name,
                  'icon': icon,
                  'budget': budgetValue,
                  'actual': currentValue,
                  'remaining': budgetValue - currentValue,
                  'percentage': budgetValue > 0
                      ? (currentValue / budgetValue * 100)
                      : 0,
                });
              },
        );
      }
    }

    if (categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No categories found'),
        ),
      );
    }

    // Sort by actual spending (descending)
    categories.sort(
      (a, b) => (b['actual'] as double).compareTo(a['actual'] as double),
    );

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isOverBudget = category['actual'] > category['budget'];

          return ListTile(
            leading: Text(
              category['icon'],
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(category['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: ((category['percentage'] as double) / 100).clamp(
                    0.0,
                    1.0,
                  ),
                  backgroundColor: Colors.grey.shade200,
                  color: isOverBudget ? Colors.red : Colors.green,
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${category['actual'].toStringAsFixed(2)} of \$${category['budget'].toStringAsFixed(2)} (${category['percentage'].toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${category['remaining'].abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  isOverBudget ? 'Over' : 'Left',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
