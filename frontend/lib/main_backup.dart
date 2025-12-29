// 백업 파일 - 원본 main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 환경 변수 로드 (.env 파일에서 민감 정보 읽기)
    debugPrint('🔄 .env 파일 로딩 시작...');
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env 파일 로딩 완료');

    // 네이버 지도 SDK 초기화 (앱 실행 전 필수)
    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '';
    debugPrint('🗺️ Naver Map Client ID: ${naverMapClientId.isEmpty ? "없음" : "설정됨"}');

    if (naverMapClientId.isEmpty) {
      debugPrint('⚠️ 경고: NAVER_MAP_CLIENT_ID가 .env 파일에 설정되지 않았습니다.');
    }

    debugPrint('🔄 네이버 지도 SDK 초기화 시작...');
    await FlutterNaverMap().init(
      clientId: naverMapClientId,
    );
    debugPrint('✅ 네이버 지도 SDK 초기화 완료');
  } catch (e, stackTrace) {
    debugPrint('❌ 초기화 에러: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // 세로 모드 고정 (선택사항)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: BaroApp(),
    ),
  );
}

class BaroApp extends ConsumerWidget {
  const BaroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BARO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,

      // 한국어 지역화 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}
