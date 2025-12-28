/// 민원 카테고리 열거형
enum GrievanceCategory {
  traffic('traffic', '교통/주차', '불법주정차, 포트홀, 신호등 고장'),
  env('env', '환경/위생', '쓰레기 투기, 소음, 악취, 미세먼지'),
  safety('safety', '안전/치안', '가로등 고장, CCTV, 위험 시설물'),
  facility('facility', '공원/시설', '벤치 파손, 가로수 정비, 운동기구'),
  animal('animal', '동물', '로드킬, 유기견, 길고양이, 멧돼지/해충'),
  admin('admin', '일반행정', '불친절 신고, 행정 제안, 서류 문의'),
  etc('etc', '기타', '위 분류에 속하지 않는 모든 민원');

  const GrievanceCategory(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  /// 백엔드 값으로 카테고리 찾기
  static GrievanceCategory fromValue(String value) {
    return GrievanceCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => GrievanceCategory.etc,
    );
  }
}
