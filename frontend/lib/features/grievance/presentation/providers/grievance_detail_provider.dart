import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/grievance_entity.dart';
import 'grievance_providers.dart';

part 'grievance_detail_provider.g.dart';

/// 민원 상세 상태 관리 Provider
@riverpod
class GrievanceDetail extends _$GrievanceDetail {
  @override
  Future<GrievanceEntity> build(String grievanceId) async {
    // 민원 상세 조회
    final usecase = ref.read(getGrievanceDetailUseCaseProvider);
    final result = await usecase.call(grievanceId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (grievance) => grievance,
    );
  }

  /// 새로고침
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 공감 토글
  Future<void> toggleLike() async {
    final currentState = state;

    // Optimistic update
    state.whenData((grievance) {
      state = AsyncData(
        GrievanceEntity(
          id: grievance.id,
          title: grievance.title,
          content: grievance.content,
          category: grievance.category,
          location: grievance.location,
          latitude: grievance.latitude,
          longitude: grievance.longitude,
          likeCount: grievance.isLiked
              ? grievance.likeCount - 1
              : grievance.likeCount + 1,
          isLiked: !grievance.isLiked,
          images: grievance.images,
          createdAt: grievance.createdAt,
          updatedAt: grievance.updatedAt,
          status: grievance.status,
          userId: grievance.userId,
          userName: grievance.userName,
        ),
      );
    });

    // API 호출
    try {
      final usecase = ref.read(toggleLikeUseCaseProvider);
      final result = await usecase.call(grievanceId);

      result.fold(
        (failure) {
          // 실패 시 롤백
          state = currentState;
          throw Exception(failure.message);
        },
        (updatedGrievance) {
          // 성공 시 서버 데이터로 업데이트
          state = AsyncData(updatedGrievance);
        },
      );
    } catch (e) {
      // 에러 시 롤백
      state = currentState;
      rethrow;
    }
  }
}
