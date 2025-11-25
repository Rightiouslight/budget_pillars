import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_income.freezed.dart';
part 'recurring_income.g.dart';

@freezed
class RecurringIncome with _$RecurringIncome {
  const factory RecurringIncome({
    required String id,
    required String name,
    required double amount,
    required String accountId,
    required String pocketId,
    required int dayOfMonth,
  }) = _RecurringIncome;

  factory RecurringIncome.fromJson(Map<String, dynamic> json) =>
      _$RecurringIncomeFromJson(json);
}
