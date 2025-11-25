import 'package:freezed_annotation/freezed_annotation.dart';
import 'account.dart';
import 'transaction.dart';
import 'recurring_income.dart';

part 'monthly_budget.freezed.dart';
part 'monthly_budget.g.dart';

@freezed
class MonthlyBudget with _$MonthlyBudget {
  const factory MonthlyBudget({
    required List<Account> accounts,
    required List<Transaction> transactions,
    @Default([]) List<RecurringIncome> recurringIncomes,
    @Default({}) Map<String, bool> autoTransactionsProcessed,
    @Default({}) Map<String, bool> processedRecurringIncomes,
  }) = _MonthlyBudget;

  factory MonthlyBudget.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBudgetFromJson(json);
}
