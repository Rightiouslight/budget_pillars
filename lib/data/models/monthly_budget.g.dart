// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyBudgetImpl _$$MonthlyBudgetImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyBudgetImpl(
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      recurringIncomes:
          (json['recurringIncomes'] as List<dynamic>?)
              ?.map((e) => RecurringIncome.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      autoTransactionsProcessed:
          (json['autoTransactionsProcessed'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      processedRecurringIncomes:
          (json['processedRecurringIncomes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$$MonthlyBudgetImplToJson(
  _$MonthlyBudgetImpl instance,
) => <String, dynamic>{
  'accounts': instance.accounts.map((e) => e.toJson()).toList(),
  'transactions': instance.transactions.map((e) => e.toJson()).toList(),
  'recurringIncomes': instance.recurringIncomes.map((e) => e.toJson()).toList(),
  'autoTransactionsProcessed': instance.autoTransactionsProcessed,
  'processedRecurringIncomes': instance.processedRecurringIncomes,
};
