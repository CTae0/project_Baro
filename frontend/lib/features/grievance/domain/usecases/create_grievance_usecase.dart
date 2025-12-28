import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/grievance_entity.dart';
import '../repositories/grievance_repository.dart';

/// 민원 생성 파라미터
class CreateGrievanceParams {
  final String title;
  final String content;
  final String category;
  final double latitude;
  final double longitude;
  final List<String> imagePaths;

  CreateGrievanceParams({
    required this.title,
    required this.content,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.imagePaths,
  });
}

/// 민원 생성 UseCase
class CreateGrievanceUseCase {
  final GrievanceRepository repository;

  CreateGrievanceUseCase(this.repository);

  Future<Either<Failure, GrievanceEntity>> call(CreateGrievanceParams params) {
    return repository.createGrievance(
      title: params.title,
      content: params.content,
      category: params.category,
      latitude: params.latitude,
      longitude: params.longitude,
      imagePaths: params.imagePaths,
    );
  }
}
