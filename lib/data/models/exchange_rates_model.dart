import '../../domain/entities/exchange_rates.dart';

class ExchangeRatesModel extends ExchangeRates {
  const ExchangeRatesModel({
    required super.base,
    required super.rates,
    required super.timestamp,
  });

  factory ExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    final ratesMap = json['rates'] as Map<String, dynamic>;
    final rates = ratesMap.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    final ts = json['timestamp'];
    final timestamp = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
        : DateTime.now();

    return ExchangeRatesModel(
      base: json['base'] as String,
      rates: rates,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'base': base,
    'rates': rates,
    'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
  };

  factory ExchangeRatesModel.fromEntity(ExchangeRates entity) =>
      ExchangeRatesModel(
        base: entity.base,
        rates: entity.rates,
        timestamp: entity.timestamp,
      );
}
