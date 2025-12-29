import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

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

    // Kakao SDK 초기화 (모바일에서만 실행)
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile) {
      final kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
      if (kakaoNativeAppKey.isNotEmpty) {
        debugPrint('🔄 Kakao SDK 초기화 시작...');
        KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
        debugPrint('✅ Kakao SDK 초기화 완료');
      } else {
        debugPrint('⚠️ 경고: KAKAO_NATIVE_APP_KEY가 .env 파일에 설정되지 않았습니다.');
      }
    }

    // 네이버 지도 SDK 초기화 (모바일에서만 실행)
    // Web, Windows, macOS, Linux에서는 네이버 지도 SDK를 지원하지 않음
    if (isMobile) {
      final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '';
      debugPrint('🗺️ Naver Map Client ID: ${naverMapClientId.isEmpty ? "없음" : "설정됨"}');

      if (naverMapClientId.isEmpty) {
        debugPrint('⚠️ 경고: NAVER_MAP_CLIENT_ID가 .env 파일에 설정되지 않았습니다.');
      }

      debugPrint('🔄 네이버 지도 SDK 초기화 시작...');
      await NaverMapSdk.instance.initialize(
        clientId: naverMapClientId,
      );
      debugPrint('✅ 네이버 지도 SDK 초기화 완료');
    } else {
      debugPrint('ℹ️ 현재 플랫폼에서는 네이버 지도와 Kakao SDK가 지원되지 않습니다 (모바일 앱에서만 사용 가능)');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ 초기화 에러: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  // 세로 모드 고정 (선택사항)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('🚀 앱 실행 시작...');
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
    debugPrint('📱 BaroApp build 호출됨');

    try {
      final router = ref.watch(appRouterProvider);
      debugPrint('✅ Router 생성 완료');

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
    } catch (e, stackTrace) {
      debugPrint('❌ BaroApp build 에러: $e');
      debugPrint('Stack trace: $stackTrace');

      // 에러 발생 시 기본 에러 화면 표시
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('앱 로딩 중 에러 발생'),
                const SizedBox(height: 8),
                Text(e.toString()),
              ],
            ),
          ),
        ),
      );
    }
  }
}
