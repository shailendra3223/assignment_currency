import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class CurrencyInput extends Equatable {
  final String id;
  final String currencyCode;
  final String amount;

  CurrencyInput({String? id, required this.currencyCode, this.amount = ''})
    : id = id ?? const Uuid().v4();

  double get parsedAmount => double.tryParse(amount) ?? 0.0;

  bool get hasValidAmount =>
      double.tryParse(amount) != null && parsedAmount >= 0;

  CurrencyInput copyWith({String? currencyCode, String? amount}) {
    return CurrencyInput(
      id: id,
      currencyCode: currencyCode ?? this.currencyCode,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [id, currencyCode, amount];
}
