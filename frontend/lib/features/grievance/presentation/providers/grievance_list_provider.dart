import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/grievance_entity.dart';
import 'grievance_providers.dart';

part 'grievance_list_provider.g.dart';

/// 민원 리스트 상태 관리 Provider
@riverpod
class GrievanceList extends _$GrievanceList {
  @override
  Future<List<GrievanceEntity>> build() async {
    // 민원 리스트 조회
    final usecase = ref.read(getGrievancesUseCaseProvider);
    final result = await usecase.call();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (grievances) => grievances,
    );
  }

  /// 새로고침
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 수동으로 상태 업데이트 (Optimistic update용)
  void updateGrievance(GrievanceEntity updated) {
    state.whenData((grievances) {
      final index = grievances.indexWhere((g) => g.id == updated.id);
      if (index != -1) {
        final newList = [...grievances];
        newList[index] = updated;
        state = AsyncData(newList);
      }
    });
  }
}
