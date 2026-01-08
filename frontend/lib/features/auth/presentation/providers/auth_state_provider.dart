import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_providers.dart';

part 'auth_state_provider.g.dart';

/// 전역 인증 상태 관리 프로바이더
/// 앱 전체에서 사용자 로그인 상태를 관리
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<UserEntity?> build() async {
    // 초기화 시 토큰 확인 후 사용자 정보 조회
    final repository = ref.read(authRepositoryProvider);
    final isLoggedIn = await repository.isLoggedIn();

    if (!isLoggedIn) return null;

    final usecase = ref.read(getCurrentUserUseCaseProvider);
    final result = await usecase.call();

    return result.fold(
      (failure) {
        // 토큰이 유효하지 않으면 null 반환
        return null;
      },
      (user) => user,
    );
  }

  /// 이메일로 회원가입
  Future<void> register({
    required String email,
    required String password,
    required String password2,
    String? name,
    String? phoneNumber,
    String? nickname,
    String? role,
  }) async {
    state = const AsyncLoading();

    final usecase = ref.read(registerUseCaseProvider);
    final result = await usecase.call(
      email: email,
      password: password,
      password2: password2,
      name: name,
      phoneNumber: phoneNumber,
      nickname: nickname,
      role: role,
    );

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  /// 이메일로 로그인
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final usecase = ref.read(loginWithEmailUseCaseProvider);
    final result = await usecase.call(email: email, password: password);

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  /// Kakao로 로그인
  Future<void> loginWithKakao() async {
    state = const AsyncLoading();

    final usecase = ref.read(loginWithKakaoUseCaseProvider);
    final result = await usecase.call();

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  /// Naver로 로그인
  Future<void> loginWithNaver() async {
    state = const AsyncLoading();

    final usecase = ref.read(loginWithNaverUseCaseProvider);
    final result = await usecase.call();

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    final usecase = ref.read(logoutUseCaseProvider);
    await usecase.call();

    state = const AsyncData(null);
  }

  /// 사용자 정보 새로고침
  Future<void> refresh() async {
    final usecase = ref.read(getCurrentUserUseCaseProvider);
    final result = await usecase.call();

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }
}
