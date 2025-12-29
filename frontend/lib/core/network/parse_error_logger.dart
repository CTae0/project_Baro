import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:retrofit/retrofit.dart';

/// Custom ParseErrorLogger implementation for Retrofit
/// Note: This implementation matches the 3-parameter signature used by retrofit_generator 9.7.0
class CustomParseErrorLogger extends ParseErrorLogger {
  final Logger _logger = Logger();

  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options, [
    dynamic data,
  ]) {
    _logger.e(
      'Retrofit Parse Error',
      error: error,
      stackTrace: stackTrace,
    );
    _logger.e('Request: ${options.method} ${options.uri}');
    if (data != null) {
      _logger.e('Data: $data');
    }
  }
}
