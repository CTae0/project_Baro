/// Django REST Framework 페이지네이션 응답 모델
class PaginatedResponse<T> {
  /// 전체 아이템 개수
  final int count;

  /// 다음 페이지 URL
  final String? next;

  /// 이전 페이지 URL
  final String? previous;

  /// 현재 페이지의 결과 리스트
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => toJsonT(e)).toList(),
    };
  }
}
