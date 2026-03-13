class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error', this.statusCode});
  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network error'});
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error'});
  @override
  String toString() => 'CacheException: $message';
}

class ApiKeyException implements Exception {
  final String message;
  const ApiKeyException({this.message = 'Invalid API key'});
  @override
  String toString() => 'ApiKeyException: $message';
}
