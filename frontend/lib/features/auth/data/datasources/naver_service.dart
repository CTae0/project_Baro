import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:logger/logger.dart';

/// Naver 로그인 서비스
class NaverService {
  final Logger _logger = Logger();

  /// Naver 로그인 실행
  /// Returns: Naver access token
  Future<String> login() async {
    try {
      _logger.i('Naver 로그인 시도');

      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        _logger.i('Naver 로그인 성공');

        final token = result.accessToken;
        if (token == null) {
          _logger.e('Naver 로그인 성공했으나 토큰이 없음');
          throw Exception('Naver 로그인 성공했으나 토큰이 없음');
        }

        _logger.d('Access Token: ${token.accessToken.substring(0, 20)}...');
        _logger.d('Refresh Token: ${token.refreshToken.isNotEmpty ? token.refreshToken.substring(0, 20) : "empty"}...');

        return token.accessToken;
      } else {
        _logger.e('Naver 로그인 실패: ${result.status}');
        throw Exception('Naver 로그인 실패: ${result.status}');
      }
    } catch (e) {
      _logger.e('Naver 로그인 에러: $e');
      rethrow;
    }
  }

  /// Naver 로그아웃
  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOut();
      _logger.i('Naver 로그아웃 성공');
    } catch (e) {
      _logger.e('Naver 로그아웃 실패: $e');
      rethrow;
    }
  }

  /// Naver 연결 해제
  Future<void> unlink() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
      _logger.i('Naver 연결 해제 성공');
    } catch (e) {
      _logger.e('Naver 연결 해제 실패: $e');
      rethrow;
    }
  }
}
