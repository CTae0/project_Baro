import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/kakao_service.dart';

/// AuthRepository 구현체
/// 인증 관련 비즈니스 로직을 처리하고 데이터 소스를 조합
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final KakaoService kakaoService;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.kakaoService,
  );

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await remoteDataSource.register({
        'email': email,
        'password': password,
        'password2': password2,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });

      // 토큰 저장
      await localDataSource.saveAccessToken(response.tokens.access);
      await localDataSource.saveRefreshToken(response.tokens.refresh);

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
      // 1. Kakao SDK로 access_token 받기
      final kakaoAccessToken = await kakaoService.login();

      // 2. Backend에 전송하여 JWT 받기
      final response = await remoteDataSource.loginWithKakao({
        'access_token': kakaoAccessToken,
      });

      // 3. JWT 토큰 저장
      await localDataSource.saveAccessToken(response.tokens.access);
      await localDataSource.saveRefreshToken(response.tokens.refresh);

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
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken != null) {
        await remoteDataSource.logout({'refresh': refreshToken});
      }

      // Kakao 로그아웃도 시도 (실패해도 무시)
      try {
        await kakaoService.logout();
      } catch (e) {
        // Kakao 로그아웃 실패는 무시
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
  }

  @override
  Future<void> clearTokens() {
    return localDataSource.clearTokens();
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
