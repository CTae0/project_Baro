import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Dio HTTP 클라이언트 설정
class DioClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  // 토큰 메모리 캐시
  String? _cachedToken;
  DateTime? _tokenCacheTime;
  static const _cacheExpiry = Duration(minutes: 5);

  DioClient({String? baseUrl}) {
    // .env에서 API URL 읽기 (플랫폼별 자동 선택)
    final apiUrl = baseUrl ?? _getApiUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(_createInterceptor());

    // 디버그 모드에서만 로깅 인터셉터 추가
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
      ));
    }
  }

  Dio get dio => _dio;

  /// 플랫폼별 API URL 자동 선택
  String _getApiUrl() {
    // 웹 환경에서는 localhost 사용
    if (kIsWeb) {
      final webUrl = dotenv.env['API_BASE_URL_WEB'] ?? 'http://localhost:8000/api';
      _logger.i('Platform: Web - Using API URL: $webUrl');
      return webUrl;
    }

    // iOS 시뮬레이터에서는 localhost 사용
    if (!kIsWeb && Platform.isIOS) {
      final iosUrl = dotenv.env['API_BASE_URL_WEB'] ?? 'http://localhost:8000/api';
      _logger.i('Platform: iOS - Using API URL: $iosUrl');
      return iosUrl;
    }

    // Android 에뮬레이터에서는 10.0.2.2 사용
    if (!kIsWeb && Platform.isAndroid) {
      final androidUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://10.0.2.2:8000/api';
      _logger.i('Platform: Android - Using API URL: $androidUrl');
      return androidUrl;
    }

    // 기타 플랫폼 (기본값)
    final defaultUrl = dotenv.env['API_BASE_URL_DEV'] ?? 'http://localhost:8000/api';
    _logger.i('Platform: Other - Using API URL: $defaultUrl');
    return defaultUrl;
  }

  /// 커스텀 인터셉터
  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 토큰 갱신 API 호출 시 인터셉터 건너뛰기
        if (options.extra['skipAuthInterceptor'] == true) {
          _logger.d('Skipping auth interceptor for ${options.path}');
          return handler.next(options);
        }

        // JWT 토큰 자동 주입
        final token = await _getAuthToken();
        if (token != null) {
          _logger.d('토큰 추가: Bearer ${token.substring(0, 20)}...');
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          _logger.w('저장된 토큰 없음');
        }

        _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
        _logger.d('Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        );
        return handler.next(response);
      },
      onError: (error, handler) async {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
        );
        _logger.e('ERROR MESSAGE: ${error.message}');
        _logger.e('ERROR DATA: ${error.response?.data}');

        // 토큰 갱신 API 자체가 실패한 경우 재시도하지 않음
        if (error.requestOptions.extra['skipAuthInterceptor'] == true) {
          _logger.w('Token refresh API failed - not retrying');
          return handler.next(error);
        }

        // 401 Unauthorized 처리 - 토큰 갱신 시도
        if (error.response?.statusCode == 401) {
          _logger.w('401 Unauthorized - 토큰 갱신 시도');
          try {
            final newToken = await _refreshAuthToken();
            if (newToken != null) {
              _logger.i('토큰 갱신 성공 - 원래 요청 재시도');
              // 토큰 갱신 성공 - 원래 요청 재시도
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final cloneReq = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            } else {
              _logger.e('토큰 갱신 실패 - 새 토큰 없음, 저장된 토큰 삭제됨');
            }
          } catch (e) {
            _logger.e('Token refresh failed: $e');
            // 토큰 갱신 실패 - 로그아웃 필요
          }
        }

        return handler.next(error);
      },
    );
  }

  /// Access Token 가져오기 (메모리 캐싱 적용)
  Future<String?> _getAuthToken() async {
    // 캐시 유효성 체크
    if (_cachedToken != null && _tokenCacheTime != null) {
      if (DateTime.now().difference(_tokenCacheTime!) < _cacheExpiry) {
        return _cachedToken; // 캐시 사용
      }
    }

    // 캐시 만료 또는 없음 -> 스토리지 읽기
    const storage = FlutterSecureStorage();
    _cachedToken = await storage.read(key: 'access_token');
    _tokenCacheTime = DateTime.now();
    return _cachedToken;
  }

  /// 토큰 캐시 무효화 (토큰 갱신 시 호출)
  void invalidateTokenCache() {
    _cachedToken = null;
    _tokenCacheTime = null;
  }

  /// JWT 토큰 갱신
  Future<String?> _refreshAuthToken() async {
    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      _logger.w('Refresh token not found');
      return null;
    }

    try {
      // 인터셉터를 우회하여 토큰 갱신 API 호출
      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          extra: {'skipAuthInterceptor': true}, // 인터셉터 건너뛰기 플래그
        ),
      );

      final newAccessToken = response.data['access'];
      final newRefreshToken = response.data['refresh'];

      // 새 토큰 저장
      await storage.write(key: 'access_token', value: newAccessToken);
      await storage.write(key: 'refresh_token', value: newRefreshToken);

      // 캐시 무효화
      invalidateTokenCache();

      _logger.i('Token refreshed successfully');
      return newAccessToken;
    } catch (e) {
      _logger.e('Failed to refresh token: $e');
      // 토큰 갱신 실패 시 토큰 삭제
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');

      // 캐시 무효화
      invalidateTokenCache();

      return null;
    }
  }

  // GET 요청
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST 요청
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT 요청
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE 요청
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PATCH 요청
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 파일 업로드
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
