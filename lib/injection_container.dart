import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'data/datasources/local/currency_local_datasource.dart';
import 'data/datasources/remote/currency_remote_datasource.dart';
import 'data/repositories/currency_repository_impl.dart';
import 'domain/repositories/currency_repository.dart';
import 'domain/usecases/base_currency_usecases.dart';
import 'domain/usecases/calculate_total_usecase.dart';
import 'domain/usecases/get_latest_rates_usecase.dart';
import 'domain/usecases/get_symbols_usecase.dart';
import 'presentation/blocs/currency/currency_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Dio ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.apiKey,
        },
      ),
    );
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
    return dio;
  });

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ── Data sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      remoteDataSource: sl<CurrencyRemoteDataSource>(),
      localDataSource: sl<CurrencyLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ── Use cases ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetSymbolsUseCase(sl<CurrencyRepository>()));
  sl.registerLazySingleton(
    () => GetLatestRatesUseCase(sl<CurrencyRepository>()),
  );
  sl.registerLazySingleton(() => CalculateTotalUseCase());
  sl.registerLazySingleton(
    () => SaveBaseCurrencyUseCase(sl<CurrencyRepository>()),
  );
  sl.registerLazySingleton(
    () => GetBaseCurrencyUseCase(sl<CurrencyRepository>()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => CurrencyBloc(
      getSymbolsUseCase: sl<GetSymbolsUseCase>(),
      getLatestRatesUseCase: sl<GetLatestRatesUseCase>(),
      calculateTotalUseCase: sl<CalculateTotalUseCase>(),
      saveBaseCurrencyUseCase: sl<SaveBaseCurrencyUseCase>(),
      getBaseCurrencyUseCase: sl<GetBaseCurrencyUseCase>(),
    ),
  );
  sl.registerFactory(
    () => SettingsBloc(
      getBaseCurrencyUseCase: sl<GetBaseCurrencyUseCase>(),
      saveBaseCurrencyUseCase: sl<SaveBaseCurrencyUseCase>(),
      getLatestRatesUseCase: sl<GetLatestRatesUseCase>(),
    ),
  );
}
