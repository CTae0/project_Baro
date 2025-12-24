/// 서버 예외 (API 호출 실패)
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

/// 네트워크 예외 (연결 실패)
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 캐시 예외 (로컬 데이터 접근 실패)
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// 인증 예외 (401, 403)
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, [this.statusCode]);

  @override
  String toString() => 'AuthException: $message (statusCode: $statusCode)';
}

/// 유효성 검사 예외
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() => 'ValidationException: $message ${errors ?? ''}';
}
