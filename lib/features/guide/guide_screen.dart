import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Pillars Guide')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            context,
            title: 'Getting Started',
            icon: Icons.rocket_launch,
            content:
                'Budget Pillars helps you manage your finances using the envelope budgeting system. '
                'Create accounts for different aspects of your life, add pockets for savings goals, '
                'and categories for spending.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Accounts',
            icon: Icons.account_balance,
            content:
                'Accounts represent different financial areas (e.g., Personal, Business). '
                'Each account can have multiple pockets and categories.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Pockets',
            icon: Icons.folder,
            content:
                'Pockets are savings envelopes where you can set aside money for specific goals. '
                'Transfer money between pockets to organize your savings.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Categories',
            icon: Icons.category,
            content:
                'Categories track spending in different areas (e.g., Groceries, Entertainment). '
                'Set budgets for each category and log expenses as you spend.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Quick Pay',
            icon: Icons.flash_on,
            content:
                'For recurring categories, use Quick Pay to automatically log a transaction '
                'for the full remaining budget amount.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Sinking Funds',
            icon: Icons.savings,
            content:
                'Link recurring categories to pockets to create sinking funds. '
                'When you pay a linked category, money transfers to your savings pocket.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Budget Planner',
            icon: Icons.calculate,
            content:
                'Use the Budget Planner to see your total income and allocate budgets '
                'across all your categories. Available in each account\'s menu.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Reports',
            icon: Icons.bar_chart,
            content:
                'View spending reports and visualizations to understand your financial habits. '
                'Track trends over time and identify areas for improvement.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
