import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../providers/active_budget_provider.dart';
import '../../data/firebase/firestore_repository.dart';
import '../../data/firebase/auth_repository.dart';
import '../../data/models/monthly_budget.dart';
import '../dashboard/dashboard_controller.dart';
import 'download_helper.dart';

class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Section
            _buildSectionTitle(context, 'Export'),
            const SizedBox(height: 16),
            _buildExportCard(context, ref),
            const SizedBox(height: 32),

            // Import Section
            _buildSectionTitle(context, 'Import'),
            const SizedBox(height: 16),
            _buildImportCard(context, ref),
            const SizedBox(height: 32),

            // CSV Template Section
            _buildSectionTitle(context, 'CSV Templates'),
            const SizedBox(height: 16),
            _buildTemplateCard(context, ref),
          ],
        ),
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

  Widget _buildExportCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Budget Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Export your current budget month as a JSON file for backup or transfer.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _exportBudgetJson(context, ref),
              icon: const Icon(Icons.download),
              label: const Text('Export as JSON'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import Data', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Import expenses from CSV files or restore a budget from JSON backup.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _importExpensesFromCsv(context, ref),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import Expenses (CSV)'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _importBudgetFromJson(context, ref),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Budget (JSON)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download CSV Templates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Download template CSV files to help format your data for import.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _downloadExpenseTemplate(context),
              icon: const Icon(Icons.file_download),
              label: const Text('Download Expense Template'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBudgetJson(BuildContext context, WidgetRef ref) async {
    try {
      final budget = ref.read(activeBudgetProvider).value;
      final budgetInfo = ref.read(activeBudgetInfoProvider);
      if (budget == null || budgetInfo == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No budget data to export')),
        );
        return;
      }

      // Convert budget to JSON
      final jsonData = json.encode(budget.toJson());

      // Download the file
      final bytes = Uint8List.fromList(utf8.encode(jsonData));
      downloadFile('budget_${budgetInfo.monthKey}.json', bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget exported successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importBudgetFromJson(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to read file')));
        return;
      }

      // Parse JSON
      final jsonString = utf8.decode(file.bytes!);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final budget = MonthlyBudget.fromJson(jsonData);

      // Show confirmation dialog
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Budget'),
          content: const Text(
            'This will restore budget data for the selected month. '
            'Any existing data for this month will be overwritten. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Save to Firestore using current month key
      final repository = ref.read(firestoreRepositoryProvider);
      final userId = ref.read(currentUserProvider)!.uid;
      final monthKey = ref.read(activeBudgetInfoProvider)!.monthKey;

      await repository.saveBudget(userId, monthKey, budget);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget restored successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<void> _importExpensesFromCsv(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to read file')));
        return;
      }

      // Parse CSV
      final csvString = utf8.decode(file.bytes!);
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV file is empty or invalid')),
        );
        return;
      }

      // Expected format: Date, Category, Amount, Description
      final budget = ref.read(activeBudgetProvider).value;
      if (budget == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active budget to import into')),
        );
        return;
      }

      int successCount = 0;
      int errorCount = 0;
      final errors = <String>[];

      // Skip header row
      for (var i = 1; i < csvData.length; i++) {
        try {
          final row = csvData[i];
          if (row.length < 4) {
            errorCount++;
            errors.add('Row $i: Invalid format (expected 4 columns)');
            continue;
          }

          // Skip date column for now - using current date
          final categoryName = row[1].toString();
          final amountStr = row[2].toString();
          final description = row[3].toString();

          // Parse amount
          final amount = double.tryParse(amountStr);
          if (amount == null) {
            errorCount++;
            errors.add('Row $i: Invalid amount "$amountStr"');
            continue;
          }

          // Find category by name
          String? categoryId;
          String? accountId;

          for (final account in budget.accounts) {
            for (final card in account.cards) {
              card.when(
                pocket: (_, __, ___, ____, _____) {},
                category:
                    (
                      id,
                      name,
                      _,
                      __,
                      ___,
                      ____,
                      _____,
                      ______,
                      _______,
                      ________,
                    ) {
                      if (name.toLowerCase() == categoryName.toLowerCase()) {
                        categoryId = id;
                        accountId = account.id;
                      }
                    },
              );
              if (categoryId != null) break;
            }
            if (categoryId != null) break;
          }

          if (categoryId == null || accountId == null) {
            errorCount++;
            errors.add('Row $i: Category "$categoryName" not found');
            continue;
          }

          // Add expense (ids are guaranteed non-null here due to continue above)
          await ref
              .read(dashboardControllerProvider.notifier)
              .addExpense(
                accountId: accountId!,
                categoryId: categoryId!,
                amount: amount,
                description: description.isEmpty
                    ? 'Imported expense'
                    : description,
              );
          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Row $i: $e');
        }
      }

      // Show results
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Results'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Successfully imported: $successCount expenses'),
                if (errorCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Errors: $errorCount',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Error details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...errors
                      .take(10)
                      .map(
                        (e) =>
                            Text('• $e', style: const TextStyle(fontSize: 12)),
                      ),
                  if (errors.length > 10)
                    Text('... and ${errors.length - 10} more errors'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _downloadExpenseTemplate(BuildContext context) {
    const csvContent = '''Date,Category,Amount,Description
2025-01-15,Groceries,125.50,Weekly shopping
2025-01-16,Gas,45.00,Fuel for car
2025-01-17,Dining Out,32.75,Lunch with friends''';

    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    downloadFile('expense_template.csv', bytes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template downloaded')));
  }
}
