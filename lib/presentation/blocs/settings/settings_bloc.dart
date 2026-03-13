import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/base_currency_usecases.dart';
import '../../../domain/usecases/get_latest_rates_usecase.dart';
import '../../../domain/usecases/usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class ChangeBaseCurrencyEvent extends SettingsEvent {
  final String currency;
  const ChangeBaseCurrencyEvent(this.currency);
  @override
  List<Object?> get props => [currency];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final String baseCurrency;
  final bool isSaving;

  const SettingsLoaded({required this.baseCurrency, this.isSaving = false});

  SettingsLoaded copyWith({String? baseCurrency, bool? isSaving}) =>
      SettingsLoaded(
        baseCurrency: baseCurrency ?? this.baseCurrency,
        isSaving: isSaving ?? this.isSaving,
      );

  @override
  List<Object?> get props => [baseCurrency, isSaving];
}

class SettingsSaved extends SettingsState {
  final String baseCurrency;
  const SettingsSaved({required this.baseCurrency});
  @override
  List<Object?> get props => [baseCurrency];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetBaseCurrencyUseCase getBaseCurrencyUseCase;
  final SaveBaseCurrencyUseCase saveBaseCurrencyUseCase;
  final GetLatestRatesUseCase getLatestRatesUseCase;

  SettingsBloc({
    required this.getBaseCurrencyUseCase,
    required this.saveBaseCurrencyUseCase,
    required this.getLatestRatesUseCase,
  }) : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ChangeBaseCurrencyEvent>(_onChange);
  }

  Future<void> _onLoad(LoadSettingsEvent e, Emitter<SettingsState> emit) async {
    final result = await getBaseCurrencyUseCase(const NoParams());
    result.fold(
      (f) => emit(SettingsError(message: f.message)),
      (c) => emit(SettingsLoaded(baseCurrency: c)),
    );
  }

  Future<void> _onChange(
      ChangeBaseCurrencyEvent e, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final current = state as SettingsLoaded;
      emit(current.copyWith(isSaving: true));
      final result = await saveBaseCurrencyUseCase(e.currency);
      result.fold(
        (_) => emit(current.copyWith(isSaving: false)),
        (_) => emit(SettingsSaved(baseCurrency: e.currency)),
      );
    }
  }
}
