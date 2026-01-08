import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

/// 스플래시 화면
///
/// 앱 시작 시 BARO 로고를 표시하고,
/// 인증 상태를 확인한 후 적절한 페이지로 이동합니다.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 페이드인 애니메이션 설정 (0.0 -> 1.0, 1초 동안)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // 애니메이션 시작
    _controller.forward();

    // 인증 확인 및 페이지 이동
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // 스플래시 화면 최소 표시 시간 (2초)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 인증 상태 확인
    final authState = ref.read(authStateProvider);
    final isLoggedIn = authState.value != null;

    // 인증 상태에 따라 페이지 이동
    if (isLoggedIn) {
      context.go(Routes.grievanceList);
    } else {
      context.go(Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/logo_splash.png',
            width: 300,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
