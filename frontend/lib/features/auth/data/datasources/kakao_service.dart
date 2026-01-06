import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

/// Kakao SDK 서비스
/// Kakao 로그인 처리
class KakaoService {
  final Logger _logger = Logger();

  /// Kakao 로그인 실행
  /// 카카오톡 앱이 설치되어 있으면 앱으로 로그인, 아니면 웹으로 로그인
  /// Returns: Kakao access token
  Future<String> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      _logger.i('카카오톡 설치 여부: $isInstalled');

      OAuthToken token;
      if (isInstalled) {
        _logger.i('카카오톡으로 로그인 시도');
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } on Exception catch (e) {
          // 카카오톡 로그인 실패 시 웹 로그인으로 폴백
          _logger.w('카카오톡 로그인 실패, 웹 로그인 시도: $e');
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        _logger.i('카카오 계정으로 로그인 시도');
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      _logger.i('Kakao 로그인 성공');
      _logger.d('Access Token: ${token.accessToken.substring(0, 20)}...');
      _logger.d('Refresh Token available: ${token.refreshToken != null}');

      // 토큰 유효성 검증 (옵션)
      try {
        final tokenInfo = await UserApi.instance.accessTokenInfo();
        _logger.i('토큰 유효 - 남은 시간: ${tokenInfo.expiresIn}초');
      } catch (e) {
        _logger.w('토큰 검증 실패 (계속 진행): $e');
      }

      return token.accessToken;
    } catch (e) {
      _logger.e('Kakao 로그인 실패: $e');
      rethrow;
    }
  }

  /// Kakao 로그아웃
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      _logger.i('Kakao 로그아웃 성공');
    } catch (e) {
      _logger.e('Kakao 로그아웃 실패: $e');
      rethrow;
    }
  }

  /// Kakao 연결 해제 (회원 탈퇴)
  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      _logger.i('Kakao 연결 해제 성공');
    } catch (e) {
      _logger.e('Kakao 연결 해제 실패: $e');
      rethrow;
    }
  }
}
