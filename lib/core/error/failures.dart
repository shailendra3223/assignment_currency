import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({super.message = 'Server error occurred.', this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load cached data.'});
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message = 'Invalid input provided.'});
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure({super.message = 'Invalid API key. Please check your configuration.'});
}
