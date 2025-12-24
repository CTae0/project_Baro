import 'package:freezed_annotation/freezed_annotation.dart';

part 'grievance_entity.freezed.dart';

/// 민원 엔티티
///
/// 비즈니스 로직에서 사용하는 불변 데이터 모델
@freezed
class GrievanceEntity with _$GrievanceEntity {
  const factory GrievanceEntity({
    required String id,
    required String title,
    required String content,
    required String location,
    required double latitude,
    required double longitude,
    required int likeCount,
    required bool isLiked,
    required List<String> images,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String status, // 'pending', 'in_progress', 'resolved'
    String? userId,
    String? userName,
  }) = _GrievanceEntity;

  const GrievanceEntity._();

  /// 진행 중인 민원인지 확인
  bool get isInProgress => status == 'in_progress';

  /// 해결된 민원인지 확인
  bool get isResolved => status == 'resolved';

  /// 대기 중인 민원인지 확인
  bool get isPending => status == 'pending';
}
