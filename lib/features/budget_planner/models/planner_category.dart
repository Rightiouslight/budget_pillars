import 'package:freezed_annotation/freezed_annotation.dart';

part 'planner_category.freezed.dart';
part 'planner_category.g.dart';

/// Category data for the budget planner
@freezed
class PlannerCategory with _$PlannerCategory {
  const factory PlannerCategory({
    required String id,
    required String name,
    required String icon,
    required String accountId,
    required double originalValue,
    required double budgetValue,
  }) = _PlannerCategory;

  factory PlannerCategory.fromJson(Map<String, dynamic> json) =>
      _$PlannerCategoryFromJson(json);
}
