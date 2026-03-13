import 'package:equatable/equatable.dart';

class ExchangeRates extends Equatable {
  final String base;
  final Map<String, double> rates;
  final DateTime timestamp;

  const ExchangeRates({
    required this.base,
    required this.rates,
    required this.timestamp,
  });

  double? getRate(String currencyCode) => rates[currencyCode];

  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    double amountInBase;
    if (fromCurrency == base) {
      amountInBase = amount;
    } else {
      final fromRate = rates[fromCurrency];
      if (fromRate == null || fromRate == 0) return 0;
      amountInBase = amount / fromRate;
    }

    if (toCurrency == base) return amountInBase;
    final toRate = rates[toCurrency];
    if (toRate == null) return 0;
    return amountInBase * toRate;
  }

  @override
  List<Object?> get props => [base, rates, timestamp];
}
