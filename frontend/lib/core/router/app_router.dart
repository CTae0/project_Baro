import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/grievance/presentation/pages/grievance_list_page.dart';
import '../../features/grievance/presentation/pages/grievance_create_page.dart';
import '../../features/grievance/presentation/pages/grievance_detail_page.dart';

part 'app_router.g.dart';

/// 라우트 경로 상수
class Routes {
  Routes._();

  // 인증 관련
  static const String login = '/login';

  // 민원 관련
  static const String grievanceList = '/';
  static const String grievanceCreate = '/grievance/create';
  static const String grievanceDetail = '/grievance/:id';

  // 마이페이지 (향후 추가)
  // static const String profile = '/profile';
  // static const String settings = '/settings';
}

/// GoRouter Provider
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.grievanceList,
    debugLogDiagnostics: true,

    // 라우트 가드: 인증 체크
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginPage = state.matchedLocation == Routes.login;

      // 비로그인 상태에서 보호된 페이지 접근 시 로그인 페이지로
      if (!isLoggedIn && !isLoginPage) {
        return Routes.login;
      }

      // 로그인 상태에서 로그인 페이지 접근 시 홈으로
      if (isLoggedIn && isLoginPage) {
        return Routes.grievanceList;
      }

      return null; // 정상 진행
    },

    routes: [
      // 로그인 페이지
      GoRoute(
        path: Routes.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),

      // 민원 리스트 (홈 화면)
      GoRoute(
        path: Routes.grievanceList,
        name: 'grievanceList',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const GrievanceListPage(),
        ),
      ),

      // 민원 작성
      GoRoute(
        path: Routes.grievanceCreate,
        name: 'grievanceCreate',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const GrievanceCreatePage(),
          fullscreenDialog: true, // 전체 화면 모달 스타일
        ),
      ),

      // 민원 상세
      GoRoute(
        path: Routes.grievanceDetail,
        name: 'grievanceDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: GrievanceDetailPage(grievanceId: id),
          );
        },
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('페이지를 찾을 수 없습니다'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '요청하신 페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.grievanceList),
              icon: const Icon(Icons.home),
              label: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}
