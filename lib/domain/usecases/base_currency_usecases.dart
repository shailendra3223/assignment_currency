import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/currency_repository.dart';
import 'usecase.dart';

class SaveBaseCurrencyUseCase implements UseCase<void, String> {
  final CurrencyRepository repository;

  SaveBaseCurrencyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.saveBaseCurrency(params);
  }
}

class GetBaseCurrencyUseCase implements UseCase<String, NoParams> {
  final CurrencyRepository repository;

  GetBaseCurrencyUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getSavedBaseCurrency();
  }
}
