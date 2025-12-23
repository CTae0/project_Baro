import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baro/main.dart';

void main() {
  testWidgets('BARO app smoke test', (WidgetTester tester) async {
    // ProviderScope로 앱을 감싸서 테스트
    await tester.pumpWidget(
      const ProviderScope(
        child: BaroApp(),
      ),
    );

    // 앱이 정상적으로 로드되는지 확인
    expect(find.text('BARO'), findsOneWidget);
  });
}
