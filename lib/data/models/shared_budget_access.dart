import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_budget_access.freezed.dart';
part 'shared_budget_access.g.dart';

@freezed
class SharedBudgetAccess with _$SharedBudgetAccess {
  const factory SharedBudgetAccess({
    required String ownerId,
    required String ownerEmail,
    required String monthKey,
    @Default(false) bool canWrite,
  }) = _SharedBudgetAccess;

  factory SharedBudgetAccess.fromJson(Map<String, dynamic> json) =>
      _$SharedBudgetAccessFromJson(json);
}
