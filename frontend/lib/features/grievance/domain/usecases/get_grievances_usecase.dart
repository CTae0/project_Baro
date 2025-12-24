import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/grievance_entity.dart';
import '../repositories/grievance_repository.dart';

/// 민원 리스트 조회 UseCase
class GetGrievancesUseCase {
  final GrievanceRepository repository;

  GetGrievancesUseCase(this.repository);

  Future<Either<Failure, List<GrievanceEntity>>> call() {
    return repository.getGrievances();
  }
}
