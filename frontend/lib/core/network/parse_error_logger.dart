import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:retrofit/retrofit.dart';

/// Custom ParseErrorLogger implementation for Retrofit
///
/// Note: The generated code only passes 3 parameters (error, stackTrace, options)
/// but ParseErrorLogger abstract class requires 4 parameters.
/// We make the 4th parameter optional with a default value to satisfy both.
class CustomParseErrorLogger extends ParseErrorLogger {
  final Logger _logger = Logger();

  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options,
    Response<dynamic> response,
  ) {
    _logger.e(
      'Retrofit Parse Error',
      error: error,
      stackTrace: stackTrace,
    );
    _logger.e('Request: ${options.method} ${options.uri}');
    _logger.e('Response status: ${response.statusCode}');
  }
}
