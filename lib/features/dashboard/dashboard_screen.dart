import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/active_budget_provider.dart';
import '../../features/auth/auth_controller.dart';
import 'widgets/account_board_widget.dart';
import 'dialogs/add_account_dialog.dart';
import 'services/auto_payment_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Process automatic payments on dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoPaymentServiceProvider).processIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(activeBudgetProvider);
    final budgetInfo = ref.watch(activeBudgetInfoProvider);
    final monthDisplayName = ref.watch(monthDisplayNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget Pillars'),
            Text(
              monthDisplayName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          // Previous Month Button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(activeBudgetInfoProvider.notifier).previousMonth();
            },
            tooltip: 'Previous Month',
          ),
          // Next Month Button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(activeBudgetInfoProvider.notifier).nextMonth();
            },
            tooltip: 'Next Month',
          ),
          // Reports Button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              context.push('/reports');
            },
            tooltip: 'Reports',
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
          // Sign Out Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: budgetAsync.when(
        data: (budget) {
          if (budget == null) {
            // No budget exists for this month yet
            return _buildEmptyBudget(context, ref, monthDisplayName);
          }

          // Display the budget
          return _buildBudgetView(context, ref, budget);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading budget'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: budgetInfo?.canWrite == true
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddAccountDialog(),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Account',
            )
          : null,
    );
  }

  Widget _buildEmptyBudget(
    BuildContext context,
    WidgetRef ref,
    String monthName,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No budget for $monthName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first account to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddAccountDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetView(BuildContext context, WidgetRef ref, budget) {
    if (budget.accounts.isEmpty) {
      return _buildEmptyBudget(
        context,
        ref,
        ref.watch(monthDisplayNameProvider),
      );
    }

    // Calculate responsive max width for account cards
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth > 1200
        ? 400.0 // Desktop: fixed width cards
        : screenWidth > 600
        ? 380.0 // Tablet: fixed width
        : screenWidth * 0.9; // Mobile: 90% width

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < budget.accounts.length; i++) ...[
            SizedBox(
              width: cardWidth,
              height:
                  screenHeight -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  32,
              child: AccountBoardWidget(
                account: budget.accounts[i],
                accountIndex: i,
                totalAccounts: budget.accounts.length,
              ),
            ),
            if (i < budget.accounts.length - 1)
              const SizedBox(width: 16), // Gap between accounts
          ],
        ],
      ),
    );
  }
}
