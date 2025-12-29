import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

/// 인증 Repository 인터페이스
/// Data layer에서 이 인터페이스를 구현
abstract class AuthRepository {
  /// 이메일/비밀번호로 회원가입
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });

  /// 이메일/비밀번호로 로그인
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Kakao OAuth 로그인
  Future<Either<Failure, UserEntity>> loginWithKakao();

  /// 로그아웃 (토큰 블랙리스트)
  Future<Either<Failure, void>> logout();

  /// 현재 로그인한 사용자 정보 조회
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// JWT 토큰 갱신
  Future<Either<Failure, AuthTokensEntity>> refreshToken();

  /// Access Token 가져오기
  Future<String?> getAccessToken();

  /// Refresh Token 가져오기
  Future<String?> getRefreshToken();

  /// 토큰 저장
  Future<void> saveTokens(AuthTokensEntity tokens);

  /// 토큰 삭제
  Future<void> clearTokens();

  /// 로그인 상태 확인
  Future<bool> isLoggedIn();
}
