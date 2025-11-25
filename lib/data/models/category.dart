import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String icon,
    required double budgetValue,
    required double currentValue,
    String? color,
    @Default(false) bool isRecurring,
    int? dueDate,
    String? destinationPocketId,
    String? destinationAccountId,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
