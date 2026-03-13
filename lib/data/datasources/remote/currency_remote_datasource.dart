import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/currency_model.dart';
import '../../models/exchange_rates_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<Map<String, CurrencyModel>> getSymbols();
  Future<ExchangeRatesModel> getLatestRates({String base = 'USD'});
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final Dio dio;
  CurrencyRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, CurrencyModel>> getSymbols() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/symbols',
        options: Options(headers: {'apikey': AppConstants.apiKey}),
      );

      if (response.statusCode == 401) throw const ApiKeyException();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final symbolsData = data['symbols'] as Map<String, dynamic>;
        return symbolsData.map(
          (code, name) =>
              MapEntry(code, CurrencyModel.fromJson(code, name as String)),
        );
      }

      throw ServerException(
        message: 'Failed to fetch symbols',
        statusCode: response.statusCode,
      );
    } on ApiKeyException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiKeyException || e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ExchangeRatesModel> getLatestRates({String base = 'USD'}) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {'base': base},
        options: Options(headers: {'apikey': AppConstants.apiKey}),
      );

      if (response.statusCode == 401) throw const ApiKeyException();

      if (response.statusCode == 200) {
        return ExchangeRatesModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Failed to fetch rates',
        statusCode: response.statusCode,
      );
    } on ApiKeyException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiKeyException || e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
