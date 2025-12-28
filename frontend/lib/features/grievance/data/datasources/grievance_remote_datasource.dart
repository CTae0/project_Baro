import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/grievance_model.dart';

part 'grievance_remote_datasource.g.dart';

/// 민원 Remote DataSource (Retrofit API)
@RestApi()
abstract class GrievanceApi {
  factory GrievanceApi(Dio dio, {String? baseUrl}) = _GrievanceApi;

  /// 민원 리스트 조회
  @GET('/grievances/')
  Future<List<GrievanceModel>> getGrievances();

  /// 민원 상세 조회
  @GET('/grievances/{id}/')
  Future<GrievanceModel> getGrievanceById(@Path('id') String id);

  /// 민원 생성 (Multipart - 이미지 포함)
  @POST('/grievances/')
  @MultiPart()
  Future<GrievanceModel> createGrievance(
    @Part(name: 'title') String title,
    @Part(name: 'content') String content,
    @Part(name: 'category') String category,
    @Part(name: 'latitude') double latitude,
    @Part(name: 'longitude') double longitude,
    @Part(name: 'images') List<MultipartFile> images,
  );

  /// 민원 공감 토글
  @PATCH('/grievances/{id}/like/')
  Future<GrievanceModel> toggleLike(@Path('id') String id);

  /// 민원 삭제
  @DELETE('/grievances/{id}/')
  Future<void> deleteGrievance(@Path('id') String id);
}
