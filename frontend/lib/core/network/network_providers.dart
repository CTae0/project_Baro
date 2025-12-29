import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dio_client.dart';
import 'parse_error_logger.dart';

part 'network_providers.g.dart';

/// DioClient 프로바이더
@riverpod
DioClient dioClient(DioClientRef ref) {
  return DioClient();
}

/// Dio 인스턴스 프로바이더 (Retrofit에서 사용)
@riverpod
Dio dio(DioRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return dioClient.dio;
}

/// ParseErrorLogger 프로바이더 (Retrofit에서 사용)
@riverpod
ParseErrorLogger parseErrorLogger(ParseErrorLoggerRef ref) {
  return CustomParseErrorLogger();
}
