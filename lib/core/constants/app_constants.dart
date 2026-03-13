class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.apilayer.com/exchangerates_data';
  static const String apiKey = 'UgmtCbKIckQt7TZR9iE5bE0ir8tfbQeW';

  // ── Cache ─────────────────────────────────────────────────────────────────
  static const String cachedRatesKey = 'CACHED_RATES';
  static const String cachedSymbolsKey = 'CACHED_SYMBOLS';
  static const String baseCurrencyKey = 'BASE_CURRENCY';
  static const String lastFetchTimeKey = 'LAST_FETCH_TIME';
  static const int cacheExpiryHours = 1;

  // ── Defaults ──────────────────────────────────────────────────────────────
  static const String defaultBaseCurrency = 'USD';

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'CurrencyX';
}
