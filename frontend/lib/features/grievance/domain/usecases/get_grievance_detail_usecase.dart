import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/grievance_entity.dart';
import '../repositories/grievance_repository.dart';

/// 민원 상세 조회 UseCase
class GetGrievanceDetailUseCase {
  final GrievanceRepository repository;

  GetGrievanceDetailUseCase(this.repository);

  Future<Either<Failure, GrievanceEntity>> call(String id) {
    return repository.getGrievanceById(id);
  }
}
