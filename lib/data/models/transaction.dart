import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    required String accountId,
    required String accountName,
    required String categoryId,
    required String categoryName,
    String? targetAccountId,
    String? targetPocketId,
    String? targetPocketName,
    String? sourcePocketId,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
