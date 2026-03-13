import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialDataEvent extends CurrencyEvent {
  const LoadInitialDataEvent();
}

class AddCurrencyInputEvent extends CurrencyEvent {
  const AddCurrencyInputEvent();
}

class RemoveCurrencyInputEvent extends CurrencyEvent {
  final String inputId;
  const RemoveCurrencyInputEvent(this.inputId);
  @override
  List<Object?> get props => [inputId];
}

class UpdateCurrencyCodeEvent extends CurrencyEvent {
  final String inputId;
  final String currencyCode;
  const UpdateCurrencyCodeEvent({required this.inputId, required this.currencyCode});
  @override
  List<Object?> get props => [inputId, currencyCode];
}

class UpdateAmountEvent extends CurrencyEvent {
  final String inputId;
  final String amount;
  const UpdateAmountEvent({required this.inputId, required this.amount});
  @override
  List<Object?> get props => [inputId, amount];
}

class CalculateTotalEvent extends CurrencyEvent {
  const CalculateTotalEvent();
}

class RefreshRatesEvent extends CurrencyEvent {
  const RefreshRatesEvent();
}

class ClearAllInputsEvent extends CurrencyEvent {
  const ClearAllInputsEvent();
}
