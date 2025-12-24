import 'package:equatable/equatable.dart';

/// 추상 Failure 클래스
/// 모든 실패 케이스의 부모 클래스
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// 서버 에러 (500+)
class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다']);
}

/// 네트워크 에러 (연결 실패)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해주세요']);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure([super.message = '로컬 데이터를 불러오지 못했습니다']);
}

/// 인증 에러 (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([super.message = '인증이 필요합니다']);
}

/// 유효성 검사 에러
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = '입력값을 확인해주세요']);
}

/// 알 수 없는 에러
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다']);
}
