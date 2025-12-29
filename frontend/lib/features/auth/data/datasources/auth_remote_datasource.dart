import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

/// 인증 관련 API
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// 회원가입
  @POST('/auth/register/')
  Future<AuthResponseModel> register(@Body() Map<String, dynamic> data);

  /// 이메일 로그인
  @POST('/auth/login/')
  Future<LoginResponseModel> loginWithEmail(@Body() Map<String, dynamic> data);

  /// Kakao OAuth 로그인
  @POST('/auth/kakao/')
  Future<AuthResponseModel> loginWithKakao(@Body() Map<String, dynamic> data);

  /// 로그아웃
  @POST('/auth/logout/')
  Future<void> logout(@Body() Map<String, dynamic> data);

  /// 현재 사용자 정보 조회
  @GET('/auth/me/')
  Future<UserModel> getCurrentUser();

  /// JWT 토큰 갱신
  @POST('/auth/refresh/')
  Future<LoginResponseModel> refreshToken(@Body() Map<String, dynamic> data);
}
