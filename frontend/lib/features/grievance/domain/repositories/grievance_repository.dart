import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/grievance_entity.dart';

/// 민원 Repository 인터페이스
///
/// Data Layer에서 구현됩니다.
abstract class GrievanceRepository {
  /// 민원 리스트 조회
  Future<Either<Failure, List<GrievanceEntity>>> getGrievances();

  /// 민원 상세 조회
  Future<Either<Failure, GrievanceEntity>> getGrievanceById(String id);

  /// 민원 생성
  Future<Either<Failure, GrievanceEntity>> createGrievance({
    required String title,
    required String content,
    required double latitude,
    required double longitude,
    required List<String> imagePaths,
  });

  /// 민원 공감 토글
  Future<Either<Failure, GrievanceEntity>> toggleLike(String id);

  /// 민원 삭제
  Future<Either<Failure, void>> deleteGrievance(String id);
}
