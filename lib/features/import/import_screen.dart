import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../providers/active_budget_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../data/models/import_profile.dart';
import '../../data/models/monthly_budget.dart';
import '../../data/models/user_settings.dart';
import '../../data/models/card.dart' as budget_card;
import '../../data/models/transaction.dart' as app_models;
import '../../data/firebase/auth_repository.dart';
import '../../data/firebase/firestore_repository.dart';
import '../../utils/import_utils.dart';
import '../../utils/date_utils.dart' as budget_date_utils;

enum ImportStep { upload, review }

enum TransactionStatus { newTransaction, duplicate, error }

class ParsedTransaction {
  final int id;
  final DateTime date;
  final String description;
  final double amount;
  String? categoryId;
  String? accountId;
  final TransactionStatus status;
  final String? error;

  ParsedTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.categoryId,
    this.accountId,
    required this.status,
    this.error,
  });
}

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Text editing controllers
  late TextEditingController _profileNameController;
  late TextEditingController _smsStartWordsController;
  late TextEditingController _smsStopWordsController;
  late TextEditingController _testSmsController;

  // Common state
  ImportStep _currentStep = ImportStep.upload;
  String _selectedProfileId = 'none';
  String _profileName = '';

  // CSV state
  List<String> _csvHeaders = [];
  List<List<String>> _csvRows = [];
  String? _error;
  bool _hasHeader = true;
  String _dateFormat = 'M/d/yyyy';
  ColumnMapping _columnMapping = const ColumnMapping();

  // Parsed transactions
  List<ParsedTransaction> _parsedTransactions = [];
  Set<int> _selectedRows = {};
  bool _isImporting = false;

  // SMS state
  String _smsStartWords = '';
  String _smsStopWords = '';
  String _testSms = '';
  Map<String, String>? _testResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize text controllers
    _profileNameController = TextEditingController(text: _profileName);
    _smsStartWordsController = TextEditingController(text: _smsStartWords);
    _smsStopWordsController = TextEditingController(text: _smsStopWords);
    _testSmsController = TextEditingController(text: _testSms);

    // Load first profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(userSettingsProvider).value;
      if (settings != null && settings.importProfiles.isNotEmpty) {
        setState(() {
          _selectedProfileId = settings.importProfiles.first.id;
        });
        _loadProfileSettings(); // Load the profile settings immediately
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileNameController.dispose();
    _smsStartWordsController.dispose();
    _smsStopWordsController.dispose();
    _testSmsController.dispose();
    super.dispose();
  }

  void _loadProfileSettings() {
    final settings = ref.read(userSettingsProvider).value;
    if (settings == null) return;

    final profile = settings.importProfiles
        .where((p) => p.id == _selectedProfileId)
        .firstOrNull;

    if (profile != null) {
      setState(() {
        _profileName = profile.name;
        _hasHeader = profile.hasHeader;
        _dateFormat = profile.dateFormat;
        _columnMapping = profile.columnMapping;
        _smsStartWords = profile.smsStartWords;
        _smsStopWords = profile.smsStopWords;
        _testResult = null;
      });

      // Update text controllers
      _profileNameController.text = profile.name;
      _smsStartWordsController.text = profile.smsStartWords;
      _smsStopWordsController.text = profile.smsStopWords;
    } else {
      // Reset to defaults
      setState(() {
        _profileName = '';
        _hasHeader = true;
        _dateFormat = 'M/d/yyyy';
        _columnMapping = const ColumnMapping();
        _smsStartWords = '';
        _smsStopWords = '';
        _testResult = null;
      });

      // Reset text controllers
      _profileNameController.text = '';
      _smsStartWordsController.text = '';
      _smsStopWordsController.text = '';
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      _parseFile(result.files.single.bytes!);
    }
  }

  void _parseFile(List<int> fileBytes) {
    setState(() {
      _error = null;
      _csvHeaders = [];
      _csvRows = [];
    });

    try {
      final csvString = utf8.decode(fileBytes);
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty) {
        setState(() {
          _error = 'CSV file is empty';
        });
        return;
      }

      List<String> headers;
      List<List<String>> dataRows;

      if (_hasHeader) {
        headers = rows[0].map((e) => e.toString()).toList();
        dataRows = rows
            .skip(1)
            .map((row) => row.map((e) => e.toString()).toList())
            .toList();
      } else {
        headers = List.generate(rows[0].length, (i) => 'Column ${i + 1}');
        dataRows = rows
            .map((row) => row.map((e) => e.toString()).toList())
            .toList();
      }

      // Ensure all rows have the same length
      final consistentRows = dataRows.map((row) {
        final newRow = List<String>.from(row);
        while (newRow.length < headers.length) {
          newRow.add('');
        }
        return newRow.take(headers.length).toList();
      }).toList();

      setState(() {
        _csvHeaders = headers;
        _csvRows = consistentRows;
      });

      // Auto-map if no profile selected
      if (_selectedProfileId == 'none') {
        setState(() {
          _columnMapping = autoMapColumns(_csvHeaders, _csvRows);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error parsing CSV: $e';
      });
    }
  }

  void _handleMappingChange(String csvHeader, String? appField) {
    setState(() {
      // Clear any existing mapping for this CSV header
      ColumnMapping newMapping = ColumnMapping(
        date: _columnMapping.date == csvHeader ? null : _columnMapping.date,
        description: _columnMapping.description == csvHeader
            ? null
            : _columnMapping.description,
        amount: _columnMapping.amount == csvHeader
            ? null
            : _columnMapping.amount,
      );

      // Apply new mapping
      if (appField == 'date') {
        newMapping = newMapping.copyWith(date: csvHeader);
      } else if (appField == 'description') {
        newMapping = newMapping.copyWith(description: csvHeader);
      } else if (appField == 'amount') {
        newMapping = newMapping.copyWith(amount: csvHeader);
      }

      _columnMapping = newMapping;
    });
  }

  String? _getMappedField(String csvHeader) {
    if (_columnMapping.date == csvHeader) return 'date';
    if (_columnMapping.description == csvHeader) return 'description';
    if (_columnMapping.amount == csvHeader) return 'amount';
    return 'ignore';
  }

  void _reviewTransactions() {
    final budget = ref.read(activeBudgetProvider).value;
    if (budget == null) return;

    final dateIndex = _csvHeaders.indexOf(_columnMapping.date!);
    final descriptionIndex = _csvHeaders.indexOf(_columnMapping.description!);
    final amountIndex = _csvHeaders.indexOf(_columnMapping.amount!);

    final monthStartDate = ref.read(monthStartDateProvider);
    final budgetPeriod = budget_date_utils.DateUtils.getBudgetPeriod(
      monthStartDate: monthStartDate,
    );

    // Create set of existing transactions for duplicate detection
    final existingTransactionKeys = <String>{};
    for (final txn in budget.transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(txn.date);
      final amountKey = txn.amount.abs().toStringAsFixed(2);
      existingTransactionKeys.add('$dateKey|$amountKey');
    }

    final transactions = <ParsedTransaction>[];

    for (var i = 0; i < _csvRows.length; i++) {
      final row = _csvRows[i];
      final dateStr = row[dateIndex];
      final descStr = row[descriptionIndex];
      final amountStr = row[amountIndex];

      // Parse date
      DateTime? parsedDate;
      try {
        parsedDate = DateFormat(_dateFormat).parseStrict(dateStr);
      } catch (_) {
        transactions.add(
          ParsedTransaction(
            id: i,
            date: DateTime.now(),
            description: descStr,
            amount: 0,
            status: TransactionStatus.error,
            error: 'Invalid date: "$dateStr"',
          ),
        );
        continue;
      }

      // Parse amount
      final cleanedAmount = amountStr.replaceAll(RegExp(r'[^0-9.-]+'), '');
      final parsedAmount = double.tryParse(cleanedAmount);

      if (parsedAmount == null) {
        transactions.add(
          ParsedTransaction(
            id: i,
            date: parsedDate,
            description: descStr,
            amount: 0,
            status: TransactionStatus.error,
            error: 'Invalid amount: "$amountStr"',
          ),
        );
        continue;
      }

      // Check if within budget period
      if (parsedDate.isBefore(budgetPeriod.start) ||
          parsedDate.isAfter(budgetPeriod.end)) {
        continue; // Exclude transactions outside budget month
      }

      // Check for duplicates
      final dateKey = DateFormat('yyyy-MM-dd').format(parsedDate);
      final amountKey = parsedAmount.abs().toStringAsFixed(2);
      final transactionKey = '$dateKey|$amountKey';
      final isDuplicate = existingTransactionKeys.contains(transactionKey);

      transactions.add(
        ParsedTransaction(
          id: i,
          date: parsedDate,
          description: descStr,
          amount: parsedAmount,
          status: isDuplicate
              ? TransactionStatus.duplicate
              : TransactionStatus.newTransaction,
        ),
      );
    }

    setState(() {
      _parsedTransactions = transactions;
      _selectedRows = transactions
          .where((t) => t.status == TransactionStatus.newTransaction)
          .map((t) => t.id)
          .toSet();
      _currentStep = ImportStep.review;
    });
  }

  Future<void> _saveProfile() async {
    if (_profileName.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile name required')));
      return;
    }

    final settings = ref.read(userSettingsProvider).value;
    if (settings == null) return;

    final isUpdating = _selectedProfileId != 'none';
    List<ImportProfile> newProfiles;

    if (isUpdating) {
      newProfiles = settings.importProfiles.map((p) {
        if (p.id == _selectedProfileId) {
          return p.copyWith(
            name: _profileName.trim(),
            hasHeader: _hasHeader,
            dateFormat: _dateFormat,
            columnMapping: _columnMapping,
            columnCount: _csvHeaders.isNotEmpty ? _csvHeaders.length : null,
            smsStartWords: _smsStartWords,
            smsStopWords: _smsStopWords,
          );
        }
        return p;
      }).toList();
    } else {
      final newProfile = ImportProfile(
        id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
        name: _profileName.trim(),
        hasHeader: _hasHeader,
        dateFormat: _dateFormat,
        columnMapping: _columnMapping,
        columnCount: _csvHeaders.isNotEmpty ? _csvHeaders.length : null,
        smsStartWords: _smsStartWords,
        smsStopWords: _smsStopWords,
      );
      newProfiles = [...settings.importProfiles, newProfile];
      setState(() {
        _selectedProfileId = newProfile.id;
      });
    }

    // Save to Firestore
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final repository = ref.read(firestoreRepositoryProvider);
      final updatedSettings = settings.copyWith(importProfiles: newProfiles);
      await repository.saveUserSettings(user.uid, updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUpdating ? 'Profile updated!' : 'Profile saved!'),
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    if (_selectedProfileId == 'none') return;

    final settings = ref.read(userSettingsProvider).value;
    if (settings == null) return;

    final profileToDelete = settings.importProfiles
        .where((p) => p.id == _selectedProfileId)
        .firstOrNull;
    if (profileToDelete == null) return;

    final newProfiles = settings.importProfiles
        .where((p) => p.id != _selectedProfileId)
        .toList();

    final user = ref.read(currentUserProvider);
    if (user != null) {
      final repository = ref.read(firestoreRepositoryProvider);
      final updatedSettings = settings.copyWith(importProfiles: newProfiles);
      await repository.saveUserSettings(user.uid, updatedSettings);

      setState(() {
        _selectedProfileId = 'none';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile "${profileToDelete.name}" deleted')),
        );
      }
    }
  }

  void _testSmsParse() {
    if (_testSms.isEmpty) {
      setState(() {
        _testResult = {'error': 'No sample SMS provided'};
      });
      return;
    }

    final settings = ref.read(userSettingsProvider).value;
    final currencyCode = settings?.currency?.code ?? 'USD';

    try {
      final result = extractSMSData(
        _testSms,
        currencyCode,
        _smsStartWords,
        _smsStopWords,
      );

      if (result['amount'] == 'N/A' &&
          result['description'] == 'N/A' &&
          result['date'] == 'N/A') {
        setState(() {
          _testResult = {
            'error':
                'No data could be extracted. Check your keywords and sample text.',
          };
        });
      } else {
        // Format date if valid
        String formattedDate = result['date'] ?? 'N/A';
        try {
          if (formattedDate != 'N/A') {
            final date = DateTime.parse(formattedDate);
            formattedDate = DateFormat.yMMMMd().format(date);
          }
        } catch (_) {
          formattedDate = 'Invalid Date';
        }

        setState(() {
          _testResult = {
            'amount': result['amount'] ?? 'N/A',
            'description': result['description'] ?? 'N/A',
            'date': formattedDate,
          };
        });
      }
    } catch (e) {
      setState(() {
        _testResult = {'error': 'An error occurred during parsing: $e'};
      });
    }
  }

  Future<void> _importTransactions() async {
    final budget = ref.read(activeBudgetProvider).value;
    final budgetInfo = ref.read(activeBudgetInfoProvider);
    if (budget == null || budgetInfo == null) return;

    setState(() {
      _isImporting = true;
    });

    final transactionsToImport = _parsedTransactions
        .where(
          (tx) =>
              _selectedRows.contains(tx.id) &&
              tx.categoryId != null &&
              tx.categoryId != 'ignore',
        )
        .toList();

    if (transactionsToImport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No transactions were assigned to a category or pocket',
          ),
        ),
      );
      setState(() {
        _isImporting = false;
      });
      return;
    }

    // Create a copy of the budget to modify
    final updatedBudget = budget.copyWith(
      transactions: List.from(budget.transactions),
      accounts: budget.accounts.map((account) {
        return account.copyWith(cards: List.from(account.cards));
      }).toList(),
    );

    for (final tx in transactionsToImport) {
      final accountIndex = updatedBudget.accounts.indexWhere(
        (a) => a.id == tx.accountId,
      );
      if (accountIndex == -1) continue;

      final account = updatedBudget.accounts[accountIndex];

      if (tx.amount < 0) {
        // Expense - add to category
        final categoryIndex = account.cards.indexWhere(
          (c) => c.id == tx.categoryId,
        );
        if (categoryIndex == -1) continue;

        final card = account.cards[categoryIndex];
        if (card is! budget_card.CategoryCard) continue;

        final expenseAmount = tx.amount.abs();
        final updatedCategory = card.copyWith(
          currentValue: card.currentValue + expenseAmount,
        );

        // Update default pocket balance
        final defaultPocketIndex = account.cards.indexWhere(
          (c) => c.id == account.defaultPocketId,
        );
        if (defaultPocketIndex != -1) {
          final pocket = account.cards[defaultPocketIndex];
          if (pocket is budget_card.PocketCard) {
            final updatedPocket = pocket.copyWith(
              balance: pocket.balance - expenseAmount,
            );
            account.cards[defaultPocketIndex] = updatedPocket;
          }
        }

        account.cards[categoryIndex] = updatedCategory;

        // Add transaction
        final newTransaction = app_models.Transaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}_${tx.id}',
          amount: expenseAmount,
          description: tx.description,
          date: tx.date,
          accountId: account.id,
          accountName: account.name,
          categoryId: card.id,
          categoryName: card.name,
          sourcePocketId: account.defaultPocketId,
        );
        updatedBudget.transactions.insert(0, newTransaction);
      } else {
        // Income - add to pocket
        final pocketIndex = account.cards.indexWhere(
          (c) => c.id == tx.categoryId,
        );
        if (pocketIndex == -1) continue;

        final card = account.cards[pocketIndex];
        if (card is! budget_card.PocketCard) continue;

        final updatedPocket = card.copyWith(balance: card.balance + tx.amount);

        account.cards[pocketIndex] = updatedPocket;

        // Add transaction
        final newTransaction = app_models.Transaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}_${tx.id}',
          amount: tx.amount,
          description: tx.description,
          date: tx.date,
          accountId: account.id,
          accountName: account.name,
          categoryId: card.id,
          categoryName: 'Income to ${card.name}',
          sourcePocketId: card.id,
        );
        updatedBudget.transactions.insert(0, newTransaction);
      }
    }

    try {
      final repository = ref.read(firestoreRepositoryProvider);
      await repository.saveBudget(
        budgetInfo.userId,
        budgetInfo.monthKey,
        updatedBudget,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${transactionsToImport.length} transaction(s) imported successfully',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider).value;
    final budget = ref.watch(activeBudgetProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Transactions')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.description), text: 'CSV Import'),
                Tab(icon: Icon(Icons.sms), text: 'SMS Profile Setup'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCsvImportTab(settings, budget),
                  _buildSmsProfileTab(settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCsvImportTab(UserSettings? settings, MonthlyBudget? budget) {
    if (_currentStep == ImportStep.upload) {
      return _buildUploadStep(settings);
    } else {
      return _buildReviewStep(budget);
    }
  }

  Widget _buildUploadStep(UserSettings? settings) {
    final requiredFields = [
      _columnMapping.date,
      _columnMapping.description,
      _columnMapping.amount,
    ];
    final canReview = requiredFields.every((field) => field != null);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Step 1: Profile Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Select or Create Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a saved profile or create a new one for your CSV settings.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProfileId,
                        decoration: const InputDecoration(
                          labelText: 'Import Profile',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'none',
                            child: Text('None (Create New)'),
                          ),
                          ...?settings?.importProfiles.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProfileId = value;
                            });
                            _loadProfileSettings();
                          }
                        },
                      ),
                    ),
                    if (_selectedProfileId != 'none') ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteProfile,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Step 2: Upload File
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2: Upload Your CSV File',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload a CSV file from your bank. Profile settings will be applied automatically.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Drag and drop your file here, or',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('File has a header row'),
                  value: _hasHeader,
                  onChanged: (value) {
                    setState(() {
                      _hasHeader = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),

        if (_csvHeaders.isNotEmpty) ...[
          const SizedBox(height: 16),

          // Step 3: Map Columns
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart),
                      const SizedBox(width: 8),
                      Text(
                        'Step 3: Map Columns',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us which columns contain the Date, Description, and Amount for your transactions.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _dateFormat,
                    decoration: const InputDecoration(
                      labelText: 'Date Format',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'M/d/yyyy',
                        child: Text('M/D/YYYY (e.g., 1/8/2025)'),
                      ),
                      DropdownMenuItem(
                        value: 'd/M/yyyy',
                        child: Text('D/M/YYYY (e.g., 8/1/2025)'),
                      ),
                      DropdownMenuItem(
                        value: 'yyyy-MM-dd',
                        child: Text('YYYY-MM-DD (e.g., 2025-01-08)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _dateFormat = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: _csvHeaders.map((header) {
                        return DataColumn(
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                header,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 150,
                                child: DropdownButtonFormField<String>(
                                  value: _getMappedField(header),
                                  isDense: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'ignore',
                                      child: Text('Ignore'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'date',
                                      child: Text('Date'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'description',
                                      child: Text('Description'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'amount',
                                      child: Text('Amount'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    _handleMappingChange(header, value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      rows: _csvRows.take(5).map((row) {
                        return DataRow(
                          cells: row
                              .map((cell) => DataCell(Text(cell)))
                              .toList(),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_csvRows.length > 5) ...[
                    const SizedBox(height: 8),
                    Text(
                      '...and ${_csvRows.length - 5} more rows.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Step 4: Save Profile
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.save),
                      const SizedBox(width: 8),
                      Text(
                        'Step 4: Save or Update CSV Profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save these settings as a profile for faster importing next time.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Profile Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _profileNameController,
                    onChanged: (value) {
                      setState(() {
                        _profileName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _profileName.trim().isEmpty
                          ? null
                          : _saveProfile,
                      child: Text(
                        _selectedProfileId != 'none'
                            ? 'Update Profile'
                            : 'Save New Profile',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Step 5: Review
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 5: Review and Import',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Once your columns are mapped correctly, proceed to the next step.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: canReview ? _reviewTransactions : null,
                    child: const Text('Review Transactions'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep(MonthlyBudget? budget) {
    if (budget == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get all categories and pockets
    final allCategories = <Map<String, String>>[];
    final allPockets = <Map<String, String>>[];

    for (final account in budget.accounts) {
      for (final card in account.cards) {
        if (card is budget_card.CategoryCard) {
          allCategories.add({
            'accountId': account.id,
            'categoryId': card.id,
            'label': '${account.name}: ${card.name}',
          });
        } else if (card is budget_card.PocketCard) {
          allPockets.add({
            'accountId': account.id,
            'pocketId': card.id,
            'label': '${account.name}: ${card.name}',
          });
        }
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.swap_horiz),
                              const SizedBox(width: 8),
                              Text(
                                'Step 5: Assign Transactions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Assign each transaction. Expenses (negative) go to categories, income (positive) goes to pockets.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Checkbox(
                              value:
                                  _selectedRows.isNotEmpty &&
                                  _selectedRows.length ==
                                      _parsedTransactions
                                          .where(
                                            (t) =>
                                                t.status !=
                                                TransactionStatus.error,
                                          )
                                          .length,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedRows = _parsedTransactions
                                        .where(
                                          (t) =>
                                              t.status !=
                                              TransactionStatus.error,
                                        )
                                        .map((t) => t.id)
                                        .toSet();
                                  } else {
                                    _selectedRows.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          const DataColumn(label: Text('Date')),
                          const DataColumn(label: Text('Description')),
                          const DataColumn(label: Text('Amount')),
                          const DataColumn(
                            label: SizedBox(
                              width: 250,
                              child: Text('Assign To'),
                            ),
                          ),
                        ],
                        rows: _parsedTransactions.map((tx) {
                          final isIncome = tx.amount > 0;
                          final hasError = tx.status == TransactionStatus.error;
                          final isDuplicate =
                              tx.status == TransactionStatus.duplicate;

                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((
                              states,
                            ) {
                              if (hasError) {
                                return Theme.of(
                                  context,
                                ).colorScheme.errorContainer.withOpacity(0.3);
                              }
                              if (isDuplicate) {
                                return Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest;
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: _selectedRows.contains(tx.id),
                                  onChanged: hasError
                                      ? null
                                      : (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              _selectedRows.add(tx.id);
                                            } else {
                                              _selectedRows.remove(tx.id);
                                            }
                                          });
                                        },
                                ),
                              ),
                              DataCell(
                                Text(
                                  hasError
                                      ? tx.error ?? 'Error'
                                      : DateFormat.yMMMd().format(tx.date),
                                  style: hasError
                                      ? TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontSize: 12,
                                        )
                                      : null,
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.description),
                                    if (isDuplicate)
                                      Text(
                                        'Potential Duplicate',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  NumberFormat.currency(
                                    symbol: '\$',
                                  ).format(tx.amount),
                                  style: TextStyle(
                                    color: isIncome
                                        ? Colors.green.shade700
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              DataCell(
                                DropdownButtonFormField<String>(
                                  value:
                                      tx.accountId != null &&
                                          tx.categoryId != null
                                      ? '${tx.accountId}:${tx.categoryId}'
                                      : 'ignore',
                                  isDense: true,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'ignore',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block, size: 16),
                                          SizedBox(width: 8),
                                          Text('Ignore'),
                                        ],
                                      ),
                                    ),
                                    if (isIncome)
                                      ...allPockets.map(
                                        (p) => DropdownMenuItem(
                                          value:
                                              '${p['accountId']}:${p['pocketId']}',
                                          child: Text(p['label']!),
                                        ),
                                      )
                                    else
                                      ...allCategories.map(
                                        (c) => DropdownMenuItem(
                                          value:
                                              '${c['accountId']}:${c['categoryId']}',
                                          child: Text(c['label']!),
                                        ),
                                      ),
                                  ],
                                  onChanged: hasError
                                      ? null
                                      : (value) {
                                          if (value == 'ignore') {
                                            setState(() {
                                              tx.accountId = null;
                                              tx.categoryId = null;
                                            });
                                          } else {
                                            final parts = value!.split(':');
                                            setState(() {
                                              tx.accountId = parts[0];
                                              tx.categoryId = parts[1];
                                            });
                                          }
                                        },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentStep = ImportStep.upload;
                  });
                },
                child: const Text('Back to Mapping'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _isImporting ? null : _importTransactions,
                child: Text(
                  _isImporting ? 'Importing...' : 'Import Transactions',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsProfileTab(UserSettings? settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Select Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a saved profile to edit its SMS settings, or create a new one below.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProfileId,
                        decoration: const InputDecoration(
                          labelText: 'SMS Import Profile',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'none',
                            child: Text('None (Create New)'),
                          ),
                          ...?settings?.importProfiles.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProfileId = value;
                            });
                            _loadProfileSettings();
                          }
                        },
                      ),
                    ),
                    if (_selectedProfileId != 'none') ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteProfile,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Profile Settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.save),
                    const SizedBox(width: 8),
                    Text(
                      'Step 2: Save or Update Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedProfileId != 'none'
                      ? 'Update the selected profile with the settings below.'
                      : 'Save the settings below as a new profile for future use.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Profile Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _profileNameController,
                  onChanged: (value) {
                    setState(() {
                      _profileName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // SMS Parsing Keywords
                ExpansionTile(
                  leading: const Icon(Icons.message),
                  title: const Text('SMS Parsing Keywords'),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Description Start Words',
                              hintText: 'e.g., at, for, to',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Words that come before the transaction description',
                            ),
                            controller: _smsStartWordsController,
                            onChanged: (value) {
                              setState(() {
                                _smsStartWords = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Description Stop Words',
                              hintText: 'e.g., from, on, ref',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Words that mark the end of the description',
                            ),
                            controller: _smsStopWordsController,
                            onChanged: (value) {
                              setState(() {
                                _smsStopWords = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.science, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Test Your Keywords',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Sample SMS',
                              hintText: 'Paste a sample SMS message here...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                            controller: _testSmsController,
                            onChanged: (value) {
                              setState(() {
                                _testSms = value;
                                _testResult = null;
                              });
                            },
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _testSms.isEmpty ? null : _testSmsParse,
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Test Keywords'),
                          ),
                          if (_testResult != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Test Result',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  if (_testResult!.containsKey('error'))
                                    Text(
                                      _testResult!['error']!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow(
                                      'Amount',
                                      _testResult!['amount']!,
                                    ),
                                    _buildResultRow(
                                      'Description',
                                      _testResult!['description']!,
                                    ),
                                    _buildResultRow(
                                      'Date',
                                      _testResult!['date']!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _profileName.trim().isEmpty
                        ? null
                        : _saveProfile,
                    child: Text(
                      _selectedProfileId != 'none'
                          ? 'Update Profile'
                          : 'Save New Profile',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
