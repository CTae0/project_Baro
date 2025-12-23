/// BARO 앱 상수 정의
class AppConstants {
  AppConstants._();

  // API 관련
  static const String baseUrl = 'https://api.baro.example.com';
  static const String apiVersion = 'v1';

  // 로컬 저장소 키
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // 페이지 크기
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 이미지 관련
  static const int maxImageCount = 5;
  static const int maxImageSizeMB = 10;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'heic'];

  // 타임아웃
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // 민원 상태
  static const String grievanceStatusPending = 'pending';
  static const String grievanceStatusInProgress = 'in_progress';
  static const String grievanceStatusResolved = 'resolved';
  static const String grievanceStatusRejected = 'rejected';
}
