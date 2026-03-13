import 'package:equatable/equatable.dart';
import '../../../domain/entities/currency.dart';
import '../../../domain/entities/currency_input.dart';
import '../../../domain/entities/exchange_rates.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();
  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

class CurrencyLoaded extends CurrencyState {
  final Map<String, Currency> symbols;
  final ExchangeRates rates;
  final String baseCurrency;
  final List<CurrencyInput> inputs;
  final double? calculatedTotal;
  final bool isCalculating;
  final bool isOffline;

  const CurrencyLoaded({
    required this.symbols,
    required this.rates,
    required this.baseCurrency,
    required this.inputs,
    this.calculatedTotal,
    this.isCalculating = false,
    this.isOffline = false,
  });

  CurrencyLoaded copyWith({
    Map<String, Currency>? symbols,
    ExchangeRates? rates,
    String? baseCurrency,
    List<CurrencyInput>? inputs,
    double? calculatedTotal,
    bool clearTotal = false,
    bool? isCalculating,
    bool? isOffline,
  }) {
    return CurrencyLoaded(
      symbols: symbols ?? this.symbols,
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      inputs: inputs ?? this.inputs,
      calculatedTotal:
          clearTotal ? null : (calculatedTotal ?? this.calculatedTotal),
      isCalculating: isCalculating ?? this.isCalculating,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props =>
      [symbols, rates, baseCurrency, inputs, calculatedTotal, isCalculating, isOffline];
}

class CurrencyError extends CurrencyState {
  final String message;
  const CurrencyError({required this.message});
  @override
  List<Object?> get props => [message];
}

class CurrencyRefreshing extends CurrencyLoaded {
  const CurrencyRefreshing({
    required super.symbols,
    required super.rates,
    required super.baseCurrency,
    required super.inputs,
    super.calculatedTotal,
  });
}
