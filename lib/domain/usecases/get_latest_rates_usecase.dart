import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/exchange_rates.dart';
import '../repositories/currency_repository.dart';
import 'usecase.dart';

class GetLatestRatesParams {
  final String? base;

  const GetLatestRatesParams({this.base});
}

class GetLatestRatesUseCase
    implements UseCase<ExchangeRates, GetLatestRatesParams> {
  final CurrencyRepository repository;

  GetLatestRatesUseCase(this.repository);

  @override
  Future<Either<Failure, ExchangeRates>> call(GetLatestRatesParams params) {
    return repository.getLatestRates(base: params.base);
  }
}
