import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/grievance_entity.dart';
import '../../domain/repositories/grievance_repository.dart';
import '../datasources/grievance_remote_datasource.dart';
import '../models/grievance_model.dart';

/// 민원 Repository 구현체
class GrievanceRepositoryImpl implements GrievanceRepository {
  final GrievanceApi remoteDataSource;
  final Dio dio;

  GrievanceRepositoryImpl(this.remoteDataSource, this.dio);

  @override
  Future<Either<Failure, List<GrievanceEntity>>> getGrievances() async {
    try {
      final models = await remoteDataSource.getGrievances();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrievanceEntity>> getGrievanceById(String id) async {
    try {
      final model = await remoteDataSource.getGrievanceById(id);
      return Right(model.toEntity());
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrievanceEntity>> createGrievance({
    required String title,
    required String content,
    required double latitude,
    required double longitude,
    required List<String> imagePaths,
  }) async {
    try {
      print('[DEBUG] imagePaths length: ${imagePaths.length}');
      print('[DEBUG] imagePaths.isEmpty: ${imagePaths.isEmpty}');

      // 이미지가 없을 때는 Dio로 직접 JSON 전송 (multipart 대신)
      if (imagePaths.isEmpty) {
        print('[DEBUG] Using JSON (no images)');
        final response = await dio.post(
          '/grievances/',
          data: {
            'title': title,
            'content': content,
            'latitude': latitude,
            'longitude': longitude,
          },
        );
        print('[DEBUG] Response status: ${response.statusCode}');
        final model = GrievanceModel.fromJson(response.data);
        return Right(model.toEntity());
      }

      // 이미지가 있을 때는 Multipart로 전송
      print('[DEBUG] Using Multipart (with images)');
      final images = <MultipartFile>[];
      for (final path in imagePaths) {
        final file = await MultipartFile.fromFile(path);
        images.add(file);
      }

      final model = await remoteDataSource.createGrievance(
        title,
        content,
        latitude,
        longitude,
        images,
      );
      return Right(model.toEntity());
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      print('[DEBUG] DioException: ${e.message}');
      print('[DEBUG] DioException type: ${e.type}');
      print('[DEBUG] DioException response: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('[DEBUG] Unknown error: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrievanceEntity>> toggleLike(String id) async {
    try {
      final model = await remoteDataSource.toggleLike(id);
      return Right(model.toEntity());
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGrievance(String id) async {
    try {
      await remoteDataSource.deleteGrievance(id);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// DioException을 Failure로 변환
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('요청 시간이 초과되었습니다');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const AuthFailure();
        } else if (statusCode != null && statusCode >= 500) {
          return const ServerFailure();
        } else if (statusCode == 400) {
          return ValidationFailure(
            error.response?.data['message'] ?? '잘못된 요청입니다',
          );
        }
        return ServerFailure(
          error.response?.data['message'] ?? '서버 오류가 발생했습니다',
        );

      case DioExceptionType.cancel:
        return const UnknownFailure('요청이 취소되었습니다');

      default:
        return const NetworkFailure();
    }
  }
}
