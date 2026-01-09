import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

/// Dummy ParseErrorLogger - Retrofit generator 버그 우회용
///
/// Retrofit 4.9.1의 ParseErrorLogger는 4개의 required parameters를 요구하지만,
/// retrofit_generator 9.7.0은 3개만 전달하는 버그가 있습니다.
///
/// 이 더미 구현은 절대 호출되지 않도록 null로 전달됩니다.
class DummyParseErrorLogger extends ParseErrorLogger {
  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options,
    Response response,
  ) {
    // 이 메서드는 절대 호출되지 않습니다 (errorLogger: null로 전달)
    throw UnimplementedError('DummyParseErrorLogger should never be called');
  }
}
