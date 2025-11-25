import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_income.freezed.dart';
part 'recurring_income.g.dart';

@freezed
class RecurringIncome with _$RecurringIncome {
  const factory RecurringIncome({
    required String id,
    String? name,
    String? description, // Firestore uses 'description' instead of 'name'
    required double amount,
    String? accountId,
    String? pocketId,
    required int dayOfMonth,
  }) = _RecurringIncome;

  factory RecurringIncome.fromJson(Map<String, dynamic> json) =>
      _$RecurringIncomeFromJson(json);
}
