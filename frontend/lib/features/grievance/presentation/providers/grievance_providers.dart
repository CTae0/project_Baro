import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/grievance_remote_datasource.dart';
import '../../data/repositories/grievance_repository_impl.dart';
import '../../domain/repositories/grievance_repository.dart';
import '../../domain/usecases/create_grievance_usecase.dart';
import '../../domain/usecases/get_grievance_detail_usecase.dart';
import '../../domain/usecases/get_grievances_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';

part 'grievance_providers.g.dart';

/// DioClient Provider
@riverpod
DioClient dioClient(DioClientRef ref) {
  return DioClient();
}

/// GrievanceApi Provider
@riverpod
GrievanceApi grievanceApi(GrievanceApiRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GrievanceApi(dioClient.dio);
}

/// GrievanceRepository Provider
@riverpod
GrievanceRepository grievanceRepository(GrievanceRepositoryRef ref) {
  final api = ref.watch(grievanceApiProvider);
  return GrievanceRepositoryImpl(api);
}

/// GetGrievancesUseCase Provider
@riverpod
GetGrievancesUseCase getGrievancesUseCase(GetGrievancesUseCaseRef ref) {
  final repository = ref.watch(grievanceRepositoryProvider);
  return GetGrievancesUseCase(repository);
}

/// GetGrievanceDetailUseCase Provider
@riverpod
GetGrievanceDetailUseCase getGrievanceDetailUseCase(
  GetGrievanceDetailUseCaseRef ref,
) {
  final repository = ref.watch(grievanceRepositoryProvider);
  return GetGrievanceDetailUseCase(repository);
}

/// CreateGrievanceUseCase Provider
@riverpod
CreateGrievanceUseCase createGrievanceUseCase(CreateGrievanceUseCaseRef ref) {
  final repository = ref.watch(grievanceRepositoryProvider);
  return CreateGrievanceUseCase(repository);
}

/// ToggleLikeUseCase Provider
@riverpod
ToggleLikeUseCase toggleLikeUseCase(ToggleLikeUseCaseRef ref) {
  final repository = ref.watch(grievanceRepositoryProvider);
  return ToggleLikeUseCase(repository);
}
