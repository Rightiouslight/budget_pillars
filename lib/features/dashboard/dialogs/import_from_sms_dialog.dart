import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../../data/models/account.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../providers/active_budget_provider.dart';
import '../../../providers/user_settings_provider.dart';
import '../../../utils/date_utils.dart' as app_date_utils;
import '../../../utils/sms_parser.dart';
import '../../../core/widgets/category_picker_dialog.dart';
import '../dashboard_controller.dart';

class ImportFromSmsDialog extends ConsumerStatefulWidget {
  final Account account;

  const ImportFromSmsDialog({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<ImportFromSmsDialog> createState() =>
      _ImportFromSmsDialogState();
}

class _ImportFromSmsDialogState extends ConsumerState<ImportFromSmsDialog> {
  final SmsQuery smsQuery = SmsQuery();
  final TextEditingController _phoneNumberController = TextEditingController();
  
  List<_SmsTransaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermission = false;
  bool _showDuplicates = false; // Default to hidden

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    
    // Pre-populate phone number from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsAsync = ref.read(userSettingsProvider);
      final settings = settingsAsync.value;
      if (settings != null && settings.smsImportNumber.isNotEmpty) {
        _phoneNumberController.text = settings.smsImportNumber;
      }
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.sms.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
    
    if (!status.isGranted) {
      final result = await Permission.sms.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
    }
  }

  Future<void> _fetchSmsMessages() async {
    if (_phoneNumberController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user settings for budget period and currency
      final settingsAsync = ref.read(userSettingsProvider);
      final settings = settingsAsync.value;
      final monthStartDate = settings?.monthStartDate ?? 1;
      final currencyCode = settings?.currency?.code ?? 'USD';
      
      // Get import profile for SMS parsing keywords
      final importProfile = settings?.importProfiles.isNotEmpty == true
          ? settings!.importProfiles.first
          : null;
      final startWords = importProfile?.smsStartWords ?? 'at,to';
      final stopWords = importProfile?.smsStopWords ?? 'on,Available,from acc';

      // Calculate budget period
      final budgetPeriod = app_date_utils.DateUtils.getBudgetPeriod(
        monthStartDate: monthStartDate,
      );

      // Fetch SMS messages from inbox
      final allMessages = await smsQuery.querySms(
        address: _phoneNumberController.text.trim(),
        count: 200, // Fetch more to filter by date
        sort: true, // Sort by date descending
      );

      // Filter messages within budget period
      final messagesInPeriod = allMessages.where((msg) {
        final msgDate = msg.date ?? DateTime.now();
        return msgDate.isAfter(budgetPeriod.start.subtract(const Duration(days: 1))) &&
               msgDate.isBefore(budgetPeriod.end.add(const Duration(days: 1)));
      }).toList();

      final transactions = <_SmsTransaction>[];
      final budgetAsync = ref.read(activeBudgetProvider);
      
      budgetAsync.whenData((budget) {
        if (budget != null) {
          for (final message in messagesInPeriod) {
            final messageBody = message.body ?? '';
            if (messageBody.isEmpty) continue;
            
            // Check if message contains the currency code
            if (!messageBody.toUpperCase().contains(currencyCode.toUpperCase())) {
              continue;
            }
            
            // Use the existing SMS parser
            final parsed = SmsParser.extractSMSData(
              message: messageBody,
              currencyString: currencyCode,
              startKeywordsString: startWords,
              stopKeywordsString: stopWords,
            );
            
            // Only add if valid amount was extracted
            if (parsed.amount != 'N/A' && parsed.amount != '0.00') {
              final amount = double.tryParse(parsed.amount);
              if (amount == null || amount == 0) continue;
              
              final description = parsed.description != 'N/A' 
                  ? parsed.description 
                  : 'Transaction';
              
              // Parse date or use message date
              DateTime transactionDate = message.date ?? DateTime.now();
              if (parsed.date != 'N/A') {
                try {
                  // Try parsing the extracted date
                  if (parsed.date.contains('-')) {
                    final parts = parsed.date.split('-');
                    if (parts.length == 3) {
                      // Could be dd-MMM-yyyy or yyyy-MM-dd
                      if (parts[0].length == 4) {
                        // yyyy-MM-dd format
                        transactionDate = DateTime.parse(parsed.date);
                      } else {
                        // dd-MMM-yyyy format - use DateFormat
                        transactionDate = DateFormat('dd-MMM-yyyy').parse(parsed.date);
                      }
                    }
                  }
                } catch (e) {
                  // Use message date if parsing fails
                }
              }
              
              // Check for duplicates
              final isDuplicate = budget.transactions.any((t) =>
                  t.description.toLowerCase().contains(description.toLowerCase()) &&
                  t.amount.abs() == amount &&
                  t.date.difference(transactionDate).inDays.abs() <= 1);

              transactions.add(_SmsTransaction(
                smsBody: messageBody,
                date: transactionDate,
                amount: -amount, // Negative for expenses
                description: description,
                isDuplicate: isDuplicate,
                isSelected: !isDuplicate,
                categoryId: null,
              ));
            }
          }
        }
      });

      setState(() {
        _transactions = transactions;
        _isLoading = false;
        if (messagesInPeriod.isEmpty) {
          _errorMessage = 'No messages found from this number in current budget period';
        } else if (transactions.isEmpty) {
          _errorMessage = 'No valid transactions found in ${messagesInPeriod.length} message(s). Make sure messages contain "$currencyCode".';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to read SMS: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleTransaction(int index) {
    setState(() {
      _transactions[index] = _transactions[index].copyWith(
        isSelected: !_transactions[index].isSelected,
      );
    });
  }

  void _toggleAll() {
    final allSelected = _transactions.every((t) => t.isSelected || t.isDuplicate);
    setState(() {
      _transactions = _transactions.map((t) {
        if (!t.isDuplicate) {
          return t.copyWith(isSelected: !allSelected);
        }
        return t;
      }).toList();
    });
  }

  void _updateCategory(int index, String? categoryId) {
    setState(() {
      _transactions[index] = _transactions[index].copyWith(
        categoryId: categoryId,
      );
    });
  }

  Future<void> _submitTransactions() async {
    final selectedTransactions = _transactions
        .where((t) => t.isSelected && !t.isDuplicate)
        .toList();

    if (selectedTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions selected')),
      );
      return;
    }

    // Check if all selected transactions have categories
    final missingCategories = selectedTransactions
        .where((t) => t.categoryId == null || t.categoryId!.isEmpty)
        .toList();

    if (missingCategories.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign categories to all selected transactions'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(dashboardControllerProvider.notifier);
      
      for (final transaction in selectedTransactions) {
        await controller.addExpense(
          accountId: widget.account.id,
          categoryId: transaction.categoryId!,
          amount: transaction.amount.abs(),
          description: transaction.description,
          date: transaction.date,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported ${selectedTransactions.length} transaction(s)',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Import from SMS'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sms_failed, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('SMS permission is required'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _checkPermissions,
                  child: const Text('Grant Permission'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import from SMS'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_transactions.isNotEmpty)
              TextButton.icon(
                onPressed: _isLoading ? null : _submitTransactions,
                icon: const Icon(Icons.check),
                label: Text(
                  'Submit (${_transactions.where((t) => t.isSelected).length})',
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Phone number input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter bank SMS number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _fetchSmsMessages,
                        icon: const Icon(Icons.search),
                        label: const Text('Fetch'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fetches up to 100 messages from current budget period',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Budget period info
            Consumer(
              builder: (context, ref, _) {
                final settingsAsync = ref.watch(userSettingsProvider);
                final settings = settingsAsync.value;
                if (settings == null) return const SizedBox.shrink();

                final budgetPeriod = app_date_utils.DateUtils.getBudgetPeriod(
                  monthStartDate: settings.monthStartDate,
                );

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Budget Period: ${DateFormat.MMMd().format(budgetPeriod.start)} - ${DateFormat.MMMd().format(budgetPeriod.end)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),

            // Transactions list
            if (_transactions.isNotEmpty) ...[
              // Select all header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Checkbox(
                      value: _transactions
                          .where((t) => !t.isDuplicate)
                          .every((t) => t.isSelected),
                      onChanged: (_) => _toggleAll(),
                      tristate: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select All (${_transactions.length} found)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),

              // Show duplicates toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Switch(
                      value: _showDuplicates,
                      onChanged: (value) {
                        setState(() {
                          _showDuplicates = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Show duplicate transactions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  itemCount: _showDuplicates 
                      ? _transactions.length 
                      : _transactions.where((t) => !t.isDuplicate).length,
                  itemBuilder: (context, index) {
                    final visibleTransactions = _showDuplicates
                        ? _transactions
                        : _transactions.where((t) => !t.isDuplicate).toList();
                    
                    return _TransactionItem(
                      transaction: visibleTransactions[index],
                      account: widget.account,
                      onToggle: () {
                        final actualIndex = _transactions.indexOf(visibleTransactions[index]);
                        _toggleTransaction(actualIndex);
                      },
                      onCategoryChanged: (categoryId) {
                        final actualIndex = _transactions.indexOf(visibleTransactions[index]);
                        _updateCategory(actualIndex, categoryId);
                      },
                    );
                  },
                ),
              ),
            ],

            // Empty state
            if (_transactions.isEmpty && !_isLoading && _errorMessage == null)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Enter a phone number and tap Fetch',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final _SmsTransaction transaction;
  final Account account;
  final VoidCallback onToggle;
  final ValueChanged<String?> onCategoryChanged;

  const _TransactionItem({
    required this.transaction,
    required this.account,
    required this.onToggle,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = account.cards
        .whereType<card_model.Card>()
        .where((c) => c.maybeWhen(category: (_, __, ___, ____, _____, ______, _______, ________, _________, __________) => true, orElse: () => false))
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: transaction.isDuplicate
          ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: transaction.isSelected,
                  onChanged: transaction.isDuplicate ? null : (_) => onToggle(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat.yMMMd().format(transaction.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${transaction.amount.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            if (transaction.isDuplicate)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Duplicate transaction detected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!transaction.isDuplicate)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 8, right: 16),
                child: OutlinedButton(
                  onPressed: () async {
                    final selectedCategoryId = await showDialog<String>(
                      context: context,
                      builder: (context) => CategoryPickerDialog(
                        categories: categories,
                        initialCategoryId: transaction.categoryId,
                        title: 'Select Category',
                      ),
                    );
                    if (selectedCategoryId != null) {
                      onCategoryChanged(selectedCategoryId);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    children: [
                      if (transaction.categoryId != null)
                        ...() {
                          final selectedCategory = categories.firstWhere(
                            (c) => c.maybeWhen(
                              category: (id, _, __, ___, ____, _____, ______, _______, ________, _________) => id == transaction.categoryId,
                              orElse: () => false,
                            ),
                            orElse: () => categories.first,
                          );
                          
                          return selectedCategory.maybeWhen(
                            category: (_, name, icon, __, ___, color, ____, _____, ______, _______) {
                              final iconCodePoint = int.tryParse(icon) ?? Icons.category.codePoint;
                              final colorValue = color != null ? int.tryParse(color) : null;
                              final categoryColor = colorValue != null 
                                  ? Color(colorValue) 
                                  : Theme.of(context).colorScheme.primary;
                              
                              return [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                                    size: 16,
                                    color: categoryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ];
                            },
                            orElse: () => [
                              const Icon(Icons.category_outlined, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Select Category'),
                              ),
                            ],
                          );
                        }()
                      else ...[
                        const Icon(Icons.category_outlined, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Select Category'),
                        ),
                      ],
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SmsTransaction {
  final String smsBody;
  final DateTime date;
  final double amount;
  final String description;
  final bool isDuplicate;
  final bool isSelected;
  final String? categoryId;

  _SmsTransaction({
    required this.smsBody,
    required this.date,
    required this.amount,
    required this.description,
    required this.isDuplicate,
    required this.isSelected,
    this.categoryId,
  });

  _SmsTransaction copyWith({
    String? smsBody,
    DateTime? date,
    double? amount,
    String? description,
    bool? isDuplicate,
    bool? isSelected,
    String? categoryId,
  }) {
    return _SmsTransaction(
      smsBody: smsBody ?? this.smsBody,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      isSelected: isSelected ?? this.isSelected,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
