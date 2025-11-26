import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_budget_provider.dart';
import 'widgets/account_board_widget.dart';
import 'widgets/budget_header.dart';
import 'dialogs/add_account_dialog.dart';
import 'services/auto_payment_service.dart';
import 'dashboard_controller.dart';

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
      appBar: const BudgetHeader(),
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
    final isReorderingAccounts = ref.watch(reorderAccountsModeProvider);

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

    final cardHeight =
        screenHeight -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        32;

    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: budget.accounts.length,
      onReorder: (oldIndex, newIndex) {
        if (isReorderingAccounts) {
          ref
              .read(dashboardControllerProvider.notifier)
              .reorderAccounts(oldIndex: oldIndex, newIndex: newIndex);
        }
      },
      buildDefaultDragHandles: isReorderingAccounts,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, i) {
        return Container(
          key: ValueKey(budget.accounts[i].id),
          width: cardWidth,
          height: cardHeight,
          margin: EdgeInsets.only(
            right: i < budget.accounts.length - 1 ? 16 : 0,
          ),
          child: Stack(
            children: [
              AccountBoardWidget(
                account: budget.accounts[i],
                accountIndex: i,
                totalAccounts: budget.accounts.length,
              ),
              if (isReorderingAccounts)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
