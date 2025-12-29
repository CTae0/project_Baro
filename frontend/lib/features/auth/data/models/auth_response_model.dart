import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

/// 인증 응답 모델 (Kakao 로그인, 회원가입)
@JsonSerializable()
class AuthResponseModel {
  final String message;
  final UserModel user;
  final TokensModel tokens;
  @JsonKey(name: 'is_new_user')
  final bool? isNewUser;

  AuthResponseModel({
    required this.message,
    required this.user,
    required this.tokens,
    this.isNewUser,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

/// JWT 토큰 모델
@JsonSerializable()
class TokensModel {
  final String access;
  final String refresh;

  TokensModel({
    required this.access,
    required this.refresh,
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) =>
      _$TokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}

/// 로그인 응답 모델 (이메일 로그인)
@JsonSerializable()
class LoginResponseModel {
  final String access;
  final String refresh;

  LoginResponseModel({
    required this.access,
    required this.refresh,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
