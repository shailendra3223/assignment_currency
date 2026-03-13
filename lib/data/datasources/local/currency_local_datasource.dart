import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/currency_model.dart';
import '../../models/exchange_rates_model.dart';

abstract class CurrencyLocalDataSource {
  Future<void> cacheRates(ExchangeRatesModel rates);

  Future<ExchangeRatesModel> getCachedRates();

  Future<void> cacheSymbols(Map<String, CurrencyModel> symbols);

  Future<Map<String, CurrencyModel>> getCachedSymbols();

  Future<void> saveBaseCurrency(String currency);

  Future<String> getBaseCurrency();

  Future<bool> isCacheValid();
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  final SharedPreferences sharedPreferences;

  CurrencyLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheRates(ExchangeRatesModel rates) async {
    await sharedPreferences.setString(
      AppConstants.cachedRatesKey,
      jsonEncode(rates.toJson()),
    );
    await sharedPreferences.setInt(
      AppConstants.lastFetchTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<ExchangeRatesModel> getCachedRates() async {
    final json = sharedPreferences.getString(AppConstants.cachedRatesKey);
    if (json == null)
      throw const CacheException(message: 'No cached rates found');
    try {
      return ExchangeRatesModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      throw const CacheException(message: 'Failed to parse cached rates');
    }
  }

  @override
  Future<void> cacheSymbols(Map<String, CurrencyModel> symbols) async {
    final json = jsonEncode(
      symbols.map((k, v) => MapEntry(k, {'code': v.code, 'name': v.name})),
    );
    await sharedPreferences.setString(AppConstants.cachedSymbolsKey, json);
  }

  @override
  Future<Map<String, CurrencyModel>> getCachedSymbols() async {
    final json = sharedPreferences.getString(AppConstants.cachedSymbolsKey);
    if (json == null)
      throw const CacheException(message: 'No cached symbols found');
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) {
        final v = value as Map<String, dynamic>;
        return MapEntry(key, CurrencyModel.fromJson(key, v['name'] as String));
      });
    } catch (_) {
      throw const CacheException(message: 'Failed to parse cached symbols');
    }
  }

  @override
  Future<void> saveBaseCurrency(String currency) async {
    await sharedPreferences.setString(AppConstants.baseCurrencyKey, currency);
  }

  @override
  Future<String> getBaseCurrency() async {
    return sharedPreferences.getString(AppConstants.baseCurrencyKey) ??
        AppConstants.defaultBaseCurrency;
  }

  @override
  Future<bool> isCacheValid() async {
    final lastFetch = sharedPreferences.getInt(AppConstants.lastFetchTimeKey);
    if (lastFetch == null) return false;
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastFetch),
    );
    return diff.inHours < AppConstants.cacheExpiryHours;
  }
}
