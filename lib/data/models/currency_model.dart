import '../../domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({required super.code, required super.name});

  factory CurrencyModel.fromJson(String code, String name) =>
      CurrencyModel(code: code, name: name);

  factory CurrencyModel.fromEntity(Currency entity) =>
      CurrencyModel(code: entity.code, name: entity.name);

  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}
