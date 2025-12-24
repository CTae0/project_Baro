/// API 엔드포인트 상수
class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = '/api';

  // Grievances
  static const String grievances = '/grievances';
  static const String grievanceDetail = '/grievances/{id}';
  static const String toggleLike = '/grievances/{id}/like';

  // Auth (향후 사용)
  static const String login = '/auth/login';
  static const String kakaoLogin = '/auth/kakao';
  static const String naverLogin = '/auth/naver';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';
  static const String logout = '/auth/logout';

  // Comments (향후 사용)
  static const String comments = '/grievances/{id}/comments';
}
