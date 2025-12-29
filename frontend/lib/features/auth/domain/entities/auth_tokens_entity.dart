import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens_entity.freezed.dart';

/// JWT 토큰 엔티티
/// Access token과 Refresh token을 담는 불변 객체
@freezed
class AuthTokensEntity with _$AuthTokensEntity {
  const factory AuthTokensEntity({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokensEntity;
}
