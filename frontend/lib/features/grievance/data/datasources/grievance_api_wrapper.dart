import 'package:dio/dio.dart';

import '../models/grievance_model.dart';
import '../models/paginated_response.dart';

/// GrievanceApi Wrapper (페이지네이션 처리용)
/// Retrofit이 Generic 페이지네이션을 지원하지 않아 직접 Dio로 구현
class GrievanceApiWrapper {
  final Dio dio;

  GrievanceApiWrapper(this.dio);

  /// 민원 리스트 조회 (페이지네이션)
  Future<PaginatedResponse<GrievanceModel>> getGrievances({int? page}) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/grievances/',
      queryParameters: page != null ? {'page': page} : null,
    );

    if (response.data == null) {
      throw Exception('Empty response from server');
    }

    return PaginatedResponse<GrievanceModel>.fromJson(
      response.data!,
      (json) => GrievanceModel.fromJson(json),
    );
  }
}
