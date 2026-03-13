import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/currency_input.dart';
import '../entities/exchange_rates.dart';
import 'usecase.dart';

class CalculateTotalParams {
  final List<CurrencyInput> inputs;
  final String baseCurrency;
  final ExchangeRates rates;

  const CalculateTotalParams({
    required this.inputs,
    required this.baseCurrency,
    required this.rates,
  });
}

class CalculateTotalUseCase implements UseCase<double, CalculateTotalParams> {
  @override
  Future<Either<Failure, double>> call(CalculateTotalParams params) async {
    try {
      double total = 0;
      for (final input in params.inputs) {
        if (input.hasValidAmount && input.parsedAmount > 0) {
          final converted = params.rates.convert(
            amount: input.parsedAmount,
            fromCurrency: input.currencyCode,
            toCurrency: params.baseCurrency,
          );
          total += converted;
        }
      }
      return Right(total);
    } catch (e) {
      return const Left(
        InvalidInputFailure(message: 'Failed to calculate total'),
      );
    }
  }
}
