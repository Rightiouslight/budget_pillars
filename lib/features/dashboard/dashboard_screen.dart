import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/active_budget_provider.dart';
import '../../providers/budget_override_provider.dart';
import 'widgets/account_board_widget.dart';
import 'widgets/budget_header.dart';
import 'dialogs/add_account_dialog.dart';
import 'dialogs/budget_creation_dialog.dart';
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
      if (mounted) {
        ref.read(autoPaymentServiceProvider).processIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(effectiveBudgetProvider);
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
                builder: (context) => const BudgetCreationDialog(),
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

    // Calculate responsive viewport fraction for PageView
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate viewport fraction based on fixed widths for desktop/tablet
    final viewportFraction = screenWidth > 1200
        ? 400 /
              screenWidth // Desktop: 400px fixed width
        : screenWidth > 450
        ? 380 /
              screenWidth // Tablet: 380px fixed width
        : 0.92; // Mobile: 92% viewport

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: PageView.builder(
        itemCount: budget.accounts.length,
        padEnds: false,
        controller: PageController(viewportFraction: viewportFraction),
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: AccountBoardWidget(
              account: budget.accounts[i],
              accountIndex: i,
              totalAccounts: budget.accounts.length,
            ),
          );
        },
      ),
    );
  }
}
