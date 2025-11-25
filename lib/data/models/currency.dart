import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';
part 'currency.g.dart';

@freezed
class Currency with _$Currency {
  const factory Currency({
    @Default('USD') String code, // e.g., 'USD', 'EUR', 'GBP'
    @Default('\$') String symbol, // e.g., '$', '€', '£'
    @Default('en-US') String locale, // For number formatting
  }) = _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
}
