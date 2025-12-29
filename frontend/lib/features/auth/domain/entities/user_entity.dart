import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// User domain entity
/// 사용자 정보를 나타내는 불변 엔티티
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required int id,
    required String email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImage,
    String? oauthProvider,
    String? oauthId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserEntity;

  const UserEntity._();

  /// 전체 이름 반환
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$lastName$firstName'; // 한국어 형식: 성+이름
    }
    return email;
  }

  /// OAuth 사용자 여부
  bool get isOAuthUser => oauthProvider != null;
}
