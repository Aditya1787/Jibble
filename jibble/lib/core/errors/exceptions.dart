class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'A server error occurred']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);
}

class CacheException implements Exception {}
