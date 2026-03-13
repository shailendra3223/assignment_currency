import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/entities/currency.dart';
import '../../../domain/entities/exchange_rates.dart';
import '../../../domain/repositories/currency_repository.dart';
import '../datasources/local/currency_local_datasource.dart';
import '../datasources/remote/currency_remote_datasource.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;
  final CurrencyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ── Symbols ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, Currency>>> getSymbols() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final symbols = await remoteDataSource.getSymbols();
        await localDataSource.cacheSymbols(symbols);
        return Right(_normalizeSymbols(symbols));
      } on ApiKeyException {
        return const Left(ApiKeyFailure());
      } on NetworkException {
        return _cachedSymbols();
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      }
    } else {
      return _cachedSymbols();
    }
  }

  Future<Either<Failure, Map<String, Currency>>> _cachedSymbols() async {
    try {
      final cached = await localDataSource.getCachedSymbols();
      return Right(_normalizeSymbols(cached));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }


  Map<String, Currency> _normalizeSymbols(Map<String, Currency> raw) {
    return raw.map((k, v) => MapEntry(k, Currency(code: v.code, name: v.name)));
  }

  // ── Rates ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ExchangeRates>> getLatestRates({String? base}) async {
    final savedBase = await localDataSource.getBaseCurrency();
    final baseCurrency = base ?? savedBase;

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final rates = await remoteDataSource.getLatestRates(base: baseCurrency);
        await localDataSource.cacheRates(rates);
        return Right(rates);
      } on ApiKeyException {
        return const Left(ApiKeyFailure());
      } on NetworkException {
        return _cachedRates();
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      }
    } else {
      return _cachedRates();
    }
  }

  Future<Either<Failure, ExchangeRates>> _cachedRates() async {
    try {
      final cached = await localDataSource.getCachedRates();
      return Right(cached);
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ExchangeRates>> getCachedRates() async {
    try {
      return Right(await localDataSource.getCachedRates());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ── Base currency ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> getSavedBaseCurrency() async {
    try {
      return Right(await localDataSource.getBaseCurrency());
    } catch (_) {
      return const Right('USD');
    }
  }

  @override
  Future<Either<Failure, void>> saveBaseCurrency(String currency) async {
    try {
      await localDataSource.saveBaseCurrency(currency);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
