import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// Sealed class representing either a Pocket or Category card
@Freezed(unionKey: 'type')
sealed class Card with _$Card {
  const Card._();

  @FreezedUnionValue('pocket')
  const factory Card.pocket({
    required String id,
    required String name,
    required String icon,
    required double balance,
    String? color,
  }) = PocketCard;

  @FreezedUnionValue('category')
  const factory Card.category({
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
  }) = CategoryCard;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}
