import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/grievance_entity.dart';

part 'grievance_model.g.dart';

/// 민원 데이터 모델
///
/// JSON serialization을 지원하며 Entity로 변환 가능
@JsonSerializable()
class GrievanceModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String location;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  final List<String> images;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final String status;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'user_name')
  final String? userName;

  GrievanceModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.likeCount,
    required this.isLiked,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.userId,
    this.userName,
  });

  /// JSON에서 생성
  factory GrievanceModel.fromJson(Map<String, dynamic> json) =>
      _$GrievanceModelFromJson(json);

  /// JSON으로 변환
  Map<String, dynamic> toJson() => _$GrievanceModelToJson(this);

  /// Entity로 변환
  GrievanceEntity toEntity() {
    return GrievanceEntity(
      id: id,
      title: title,
      content: content,
      category: category,
      location: location,
      latitude: latitude,
      longitude: longitude,
      likeCount: likeCount,
      isLiked: isLiked,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      userId: userId,
      userName: userName,
    );
  }

  /// Entity에서 생성
  factory GrievanceModel.fromEntity(GrievanceEntity entity) {
    return GrievanceModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      category: entity.category,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      likeCount: entity.likeCount,
      isLiked: entity.isLiked,
      images: entity.images,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      userId: entity.userId,
      userName: entity.userName,
    );
  }
}
