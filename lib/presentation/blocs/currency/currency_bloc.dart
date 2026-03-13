import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/currency.dart';
import '../../../domain/entities/currency_input.dart';
import '../../../domain/usecases/base_currency_usecases.dart';
import '../../../domain/usecases/calculate_total_usecase.dart';
import '../../../domain/usecases/get_latest_rates_usecase.dart';
import '../../../domain/usecases/get_symbols_usecase.dart';
import '../../../domain/usecases/usecase.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final GetSymbolsUseCase getSymbolsUseCase;
  final GetLatestRatesUseCase getLatestRatesUseCase;
  final CalculateTotalUseCase calculateTotalUseCase;
  final SaveBaseCurrencyUseCase saveBaseCurrencyUseCase;
  final GetBaseCurrencyUseCase getBaseCurrencyUseCase;

  CurrencyBloc({
    required this.getSymbolsUseCase,
    required this.getLatestRatesUseCase,
    required this.calculateTotalUseCase,
    required this.saveBaseCurrencyUseCase,
    required this.getBaseCurrencyUseCase,
  }) : super(const CurrencyInitial()) {
    on<LoadInitialDataEvent>(_onLoadInitialData);
    on<AddCurrencyInputEvent>(_onAddCurrencyInput);
    on<RemoveCurrencyInputEvent>(_onRemoveCurrencyInput);
    on<UpdateCurrencyCodeEvent>(_onUpdateCurrencyCode);
    on<UpdateAmountEvent>(_onUpdateAmount);
    on<CalculateTotalEvent>(_onCalculateTotal);
    on<RefreshRatesEvent>(_onRefreshRates);
    on<ClearAllInputsEvent>(_onClearAllInputs);
  }

  /// Ensures the map holds plain Currency objects (not CurrencyModel subtypes)
  /// to prevent Dart runtime type errors with firstWhere / orElse.
  Map<String, Currency> _normalize(Map<String, Currency> raw) {
    return raw.map((k, v) => MapEntry(k, Currency(code: v.code, name: v.name)));
  }

  Future<void> _onLoadInitialData(
    LoadInitialDataEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final baseCurrencyResult = await getBaseCurrencyUseCase(const NoParams());
    final baseCurrency = baseCurrencyResult.fold(
      (_) => AppConstants.defaultBaseCurrency,
      (c) => c,
    );

    final symbolsResult = await getSymbolsUseCase(const NoParams());
    final ratesResult =
        await getLatestRatesUseCase(GetLatestRatesParams(base: baseCurrency));

    symbolsResult.fold(
      (failure) => emit(CurrencyError(message: failure.message)),
      (rawSymbols) {
        ratesResult.fold(
          (failure) => emit(CurrencyError(message: failure.message)),
          (rates) {
            final symbols = _normalize(rawSymbols);
            emit(CurrencyLoaded(
              symbols: symbols,
              rates: rates,
              baseCurrency: baseCurrency,
              inputs: [
                CurrencyInput(currencyCode: 'USD'),
                CurrencyInput(currencyCode: 'EUR'),
              ],
              isOffline: false,
            ));
          },
        );
      },
    );
  }

  void _onAddCurrencyInput(
    AddCurrencyInputEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    final usedCodes = current.inputs.map((i) => i.currencyCode).toSet();
    final codes = current.symbols.keys.toList();
    final idx = codes.indexWhere((c) => !usedCodes.contains(c));
    final nextCode = idx >= 0 ? codes[idx] : codes.first;
    emit(current.copyWith(
      inputs: [...current.inputs, CurrencyInput(currencyCode: nextCode)],
      clearTotal: true,
    ));
  }

  void _onRemoveCurrencyInput(
    RemoveCurrencyInputEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    if (current.inputs.length <= 1) return;
    emit(current.copyWith(
      inputs: current.inputs.where((i) => i.id != event.inputId).toList(),
      clearTotal: true,
    ));
  }

  void _onUpdateCurrencyCode(
    UpdateCurrencyCodeEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    emit(current.copyWith(
      inputs: current.inputs.map((i) => i.id == event.inputId
          ? i.copyWith(currencyCode: event.currencyCode)
          : i).toList(),
      clearTotal: true,
    ));
  }

  void _onUpdateAmount(
    UpdateAmountEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    emit(current.copyWith(
      inputs: current.inputs.map((i) =>
          i.id == event.inputId ? i.copyWith(amount: event.amount) : i).toList(),
      clearTotal: true,
    ));
  }

  Future<void> _onCalculateTotal(
    CalculateTotalEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    emit(current.copyWith(isCalculating: true));

    final result = await calculateTotalUseCase(CalculateTotalParams(
      inputs: current.inputs,
      baseCurrency: current.baseCurrency,
      rates: current.rates,
    ));

    result.fold(
      (failure) => emit(current.copyWith(isCalculating: false, clearTotal: true)),
      (total) => emit(current.copyWith(calculatedTotal: total, isCalculating: false)),
    );
  }

  Future<void> _onRefreshRates(
    RefreshRatesEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;

    emit(CurrencyRefreshing(
      symbols: current.symbols,
      rates: current.rates,
      baseCurrency: current.baseCurrency,
      inputs: current.inputs,
      calculatedTotal: current.calculatedTotal,
    ));

    final ratesResult = await getLatestRatesUseCase(
        GetLatestRatesParams(base: current.baseCurrency));

    ratesResult.fold(
      (failure) => emit(current.copyWith(isOffline: true)),
      (rates) => emit(current.copyWith(rates: rates, isOffline: false)),
    );
  }

  void _onClearAllInputs(
    ClearAllInputsEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is! CurrencyLoaded) return;
    final current = state as CurrencyLoaded;
    emit(current.copyWith(
      inputs: current.inputs.map((i) => i.copyWith(amount: '')).toList(),
      clearTotal: true,
    ));
  }
}
