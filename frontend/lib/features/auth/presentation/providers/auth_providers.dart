import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/kakao_service.dart';
import '../../data/datasources/naver_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_kakao_usecase.dart';
import '../../domain/usecases/login_with_naver_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_providers.g.dart';

// ============================================================================
// DataSources
// ============================================================================

/// FlutterSecureStorage 프로바이더
@riverpod
FlutterSecureStorage flutterSecureStorage(FlutterSecureStorageRef ref) {
  return const FlutterSecureStorage();
}

/// AuthLocalDataSource 프로바이더
@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return AuthLocalDataSource(storage);
}

/// AuthApi 프로바이더
@riverpod
AuthApi authApi(AuthApiRef ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
}

/// KakaoService 프로바이더
@riverpod
KakaoService kakaoService(KakaoServiceRef ref) {
  return KakaoService();
}

/// NaverService 프로바이더
@riverpod
NaverService naverService(NaverServiceRef ref) {
  return NaverService();
}

// ============================================================================
// Repository
// ============================================================================

/// AuthRepository 프로바이더
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final api = ref.watch(authApiProvider);
  final localStorage = ref.watch(authLocalDataSourceProvider);
  final kakaoService = ref.watch(kakaoServiceProvider);
  final naverService = ref.watch(naverServiceProvider);
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(api, localStorage, kakaoService, naverService, dioClient);
}

// ============================================================================
// UseCases
// ============================================================================

/// 회원가입 UseCase
@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

/// 이메일 로그인 UseCase
@riverpod
LoginWithEmailUseCase loginWithEmailUseCase(LoginWithEmailUseCaseRef ref) {
  return LoginWithEmailUseCase(ref.watch(authRepositoryProvider));
}

/// Kakao 로그인 UseCase
@riverpod
LoginWithKakaoUseCase loginWithKakaoUseCase(LoginWithKakaoUseCaseRef ref) {
  return LoginWithKakaoUseCase(ref.watch(authRepositoryProvider));
}

/// Naver 로그인 UseCase
@riverpod
LoginWithNaverUseCase loginWithNaverUseCase(LoginWithNaverUseCaseRef ref) {
  return LoginWithNaverUseCase(ref.watch(authRepositoryProvider));
}

/// 로그아웃 UseCase
@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

/// 현재 사용자 조회 UseCase
@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}
