import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 로컬 토큰 저장소
/// FlutterSecureStorage를 사용하여 JWT 토큰을 안전하게 저장
class AuthLocalDataSource {
  final FlutterSecureStorage storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  AuthLocalDataSource(this.storage);

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    await storage.write(key: _accessTokenKey, value: token);
  }

  /// Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    await storage.write(key: _refreshTokenKey, value: token);
  }

  /// Access Token 가져오기
  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  /// Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}
