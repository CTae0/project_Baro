import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/kakao_service.dart';
import '../datasources/naver_service.dart';

/// AuthRepository 구현체
/// 인증 관련 비즈니스 로직을 처리하고 데이터 소스를 조합
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final KakaoService kakaoService;
  final NaverService naverService;
  final DioClient dioClient;
  final Logger _logger = Logger();

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.kakaoService,
    this.naverService,
    this.dioClient,
  );

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String password2,
    String? name,
    String? phoneNumber,
    String? nickname,
    String? role,
  }) async {
    try {
      final response = await remoteDataSource.register({
        'email': email,
        'password': password,
        'password2': password2,
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (nickname != null) 'nickname': nickname,
        if (role != null) 'role': role,
      });

      // 토큰 저장
      await localDataSource.saveAccessToken(response.tokens.access);
      await localDataSource.saveRefreshToken(response.tokens.refresh);

      // 토큰 캐시 무효화
      dioClient.invalidateTokenCache();

      return Right(response.user.toEntity());
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.loginWithEmail({
        'email': email,
        'password': password,
      });

      // 토큰 저장
      await localDataSource.saveAccessToken(response.access);
      await localDataSource.saveRefreshToken(response.refresh);

      // 토큰 캐시 무효화
      dioClient.invalidateTokenCache();

      // 사용자 정보 조회
      final userResult = await getCurrentUser();
      return userResult;
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithKakao() async {
    try {
      _logger.i('=== Kakao 로그인 시작 ===');

      // 1. Kakao SDK로 access_token 받기
      _logger.i('Step 1: Kakao SDK 로그인 시도');
      final kakaoAccessToken = await kakaoService.login();
      _logger.i('Kakao SDK 로그인 성공 - Token: ${kakaoAccessToken.substring(0, 20)}...');

      // 2. Backend에 전송하여 JWT 받기
      _logger.i('Step 2: Backend로 토큰 전송');
      final response = await remoteDataSource.loginWithKakao({
        'access_token': kakaoAccessToken,
      });
      _logger.i('Backend 응답 수신 - User ID: ${response.user.id}');

      // 3. JWT 토큰 저장
      _logger.i('Step 3: JWT 토큰 저장');
      await localDataSource.saveAccessToken(response.tokens.access);
      await localDataSource.saveRefreshToken(response.tokens.refresh);
      _logger.i('JWT 토큰 저장 완료');

      // 토큰 캐시 무효화
      dioClient.invalidateTokenCache();

      _logger.i('=== Kakao 로그인 성공 ===');
      return Right(response.user.toEntity());
    } on SocketException catch (e) {
      _logger.e('네트워크 오류: $e');
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      _logger.e('Dio 오류: ${e.response?.statusCode} - ${e.message}');
      _logger.e('응답 데이터: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      _logger.e('알 수 없는 오류: $e');
      _logger.e('StackTrace: $stackTrace');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithNaver() async {
    try {
      _logger.i('=== Naver 로그인 시작 ===');

      // 1. Naver SDK로 access_token 받기
      _logger.i('Step 1: Naver SDK 로그인 시도');
      final naverAccessToken = await naverService.login();
      _logger.i('Naver SDK 로그인 성공 - Token: ${naverAccessToken.substring(0, 20)}...');

      // 2. Backend에 전송하여 JWT 받기
      _logger.i('Step 2: Backend로 토큰 전송');
      final response = await remoteDataSource.loginWithNaver({
        'access_token': naverAccessToken,
      });
      _logger.i('Backend 응답 수신 - User ID: ${response.user.id}');

      // 3. JWT 토큰 저장
      _logger.i('Step 3: JWT 토큰 저장');
      await localDataSource.saveAccessToken(response.tokens.access);
      await localDataSource.saveRefreshToken(response.tokens.refresh);
      _logger.i('JWT 토큰 저장 완료');

      // 토큰 캐시 무효화
      dioClient.invalidateTokenCache();

      _logger.i('=== Naver 로그인 성공 ===');
      return Right(response.user.toEntity());
    } on SocketException catch (e) {
      _logger.e('네트워크 오류: $e');
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      _logger.e('Dio 오류: ${e.response?.statusCode} - ${e.message}');
      _logger.e('응답 데이터: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e, stackTrace) {
      _logger.e('알 수 없는 오류: $e');
      _logger.e('StackTrace: $stackTrace');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken != null) {
        await remoteDataSource.logout({'refresh': refreshToken});
      }

      // 소셜 로그인 로그아웃 시도 (실패해도 무시)
      try {
        await kakaoService.logout();
      } catch (e) {
        // Kakao 로그아웃 실패는 무시
      }

      try {
        await naverService.logout();
      } catch (e) {
        // Naver 로그아웃 실패는 무시
      }

      // 로컬 토큰 삭제
      await localDataSource.clearTokens();

      return const Right(null);
    } catch (e) {
      // 로그아웃은 실패해도 로컬 토큰은 삭제
      await localDataSource.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user.toEntity());
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure('Refresh token not found'));
      }

      final response =
          await remoteDataSource.refreshToken({'refresh': refreshToken});

      // 새 토큰 저장
      await localDataSource.saveAccessToken(response.access);
      await localDataSource.saveRefreshToken(response.refresh);

      // 토큰 캐시 무효화
      dioClient.invalidateTokenCache();

      return Right(AuthTokensEntity(
        accessToken: response.access,
        refreshToken: response.refresh,
      ));
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<String?> getAccessToken() {
    return localDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() {
    return localDataSource.getRefreshToken();
  }

  @override
  Future<void> saveTokens(AuthTokensEntity tokens) async {
    await localDataSource.saveAccessToken(tokens.accessToken);
    await localDataSource.saveRefreshToken(tokens.refreshToken);

    // 토큰 캐시 무효화
    dioClient.invalidateTokenCache();
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();

    // 토큰 캐시 무효화
    dioClient.invalidateTokenCache();
  }

  @override
  Future<bool> isLoggedIn() {
    return localDataSource.hasTokens();
  }

  /// DioException을 Failure로 변환
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const AuthFailure('인증이 필요합니다');
        } else if (statusCode == 400) {
          final message =
              error.response?.data['detail'] ?? '잘못된 요청입니다';
          return ServerFailure(message);
        }
        return ServerFailure('서버 오류: $statusCode');

      case DioExceptionType.cancel:
        return const UnknownFailure('요청이 취소되었습니다');

      default:
        return UnknownFailure(error.message ?? '알 수 없는 오류');
    }
  }
}
