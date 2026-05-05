class ServerException implements Exception {
  final String? message;
  const ServerException([this.message]);

  @override
  String toString() => message ?? 'ServerException';
}

class CacheException implements Exception {

}

class InvalidCredentialsException implements Exception {

}