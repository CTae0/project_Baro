import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/grievance_entity.dart';
import '../repositories/grievance_repository.dart';

/// 민원 공감 토글 UseCase
class ToggleLikeUseCase {
  final GrievanceRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Either<Failure, GrievanceEntity>> call(String grievanceId) {
    return repository.toggleLike(grievanceId);
  }
}
