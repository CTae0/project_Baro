import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// User 데이터 모델
/// Backend API와 JSON 직렬화/역직렬화를 위한 모델
@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'oauth_provider')
  final String? oauthProvider;
  @JsonKey(name: 'oauth_id')
  final String? oauthId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImage,
    this.oauthProvider,
    this.oauthId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Model을 Entity로 변환
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      oauthProvider: oauthProvider,
      oauthId: oauthId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
