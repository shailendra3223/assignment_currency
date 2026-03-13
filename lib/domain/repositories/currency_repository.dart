import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/currency.dart';
import '../entities/exchange_rates.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, Map<String, Currency>>> getSymbols();
  Future<Either<Failure, ExchangeRates>> getLatestRates({String? base});
  Future<Either<Failure, ExchangeRates>> getCachedRates();
  Future<Either<Failure, String>> getSavedBaseCurrency();
  Future<Either<Failure, void>> saveBaseCurrency(String currency);
}
