import 'package:freezed_annotation/freezed_annotation.dart';
import 'card.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required String icon,
    required String defaultPocketId,
    required List<Card> cards,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
