import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/currency.dart';
import '../repositories/currency_repository.dart';
import 'usecase.dart';

class GetSymbolsUseCase implements UseCase<Map<String, Currency>, NoParams> {
  final CurrencyRepository repository;

  GetSymbolsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, Currency>>> call(NoParams params) {
    return repository.getSymbols();
  }
}
