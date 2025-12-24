/// 민원 Mock 데이터 모델
///
/// 임시 더미 데이터를 생성하기 위한 간단한 모델입니다.
/// 향후 실제 API 연동 시 domain/entities로 교체될 예정입니다.
class GrievanceMock {
  final String id;
  final String title;
  final String content;
  final String location;
  final int likeCount;
  final String? imageUrl;

  GrievanceMock({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.likeCount,
    this.imageUrl,
  });

  /// 샘플 데이터 생성
  static List<GrievanceMock> getSampleData() {
    return [
      GrievanceMock(
        id: '1',
        title: '횡단보도 신호등 고장',
        content: '강남역 4번 출구 앞 횡단보도 신호등이 깜빡이지 않아 위험합니다. 빠른 수리 부탁드립니다.',
        location: '강남구',
        likeCount: 23,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '2',
        title: '도로 파손으로 인한 안전 문제',
        content: '서초대로 근처 도로에 큰 구멍이 나있어 차량 통행 시 위험합니다.',
        location: '서초구',
        likeCount: 15,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '3',
        title: '공원 쓰레기통 부족',
        content: '올림픽공원 내 쓰레기통이 부족해 쓰레기가 바닥에 방치되고 있습니다. 추가 설치 요청드립니다.',
        location: '송파구',
        likeCount: 31,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '4',
        title: '버스 정류장 벤치 파손',
        content: '역삼역 버스 정류장 벤치가 파손되어 앉을 수 없습니다. 교체 부탁드립니다.',
        location: '강남구',
        likeCount: 8,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '5',
        title: '어린이 놀이터 시설 노후화',
        content: '반포동 어린이 놀이터 그네와 미끄럼틀이 녹슬고 파손되어 아이들이 다칠 위험이 있습니다.',
        location: '서초구',
        likeCount: 42,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '6',
        title: '가로등 전구 교체 필요',
        content: '삼성동 주택가 가로등 여러 개가 나가있어 밤에 너무 어둡습니다.',
        location: '강남구',
        likeCount: 19,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '7',
        title: '불법 주정차 단속 요청',
        content: '학교 앞 인도에 불법 주정차가 심해 학생들이 차도로 다니고 있습니다. 단속 부탁드립니다.',
        location: '송파구',
        likeCount: 27,
        imageUrl: null,
      ),
      GrievanceMock(
        id: '8',
        title: '공중화장실 청결 문제',
        content: '코엑스 인근 공중화장실 청소가 제대로 되지 않아 악취가 심합니다.',
        location: '강남구',
        likeCount: 12,
        imageUrl: null,
      ),
    ];
  }
}
