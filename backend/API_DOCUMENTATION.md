# BARO 백엔드 API 문서

Flutter 프론트엔드 개발을 위한 완전한 API 가이드

---

## 📋 목차

1. [기본 정보](#기본-정보)
2. [인증](#인증)
3. [민원 API](#민원-api)
4. [유저 API](#유저-api)
5. [데이터 모델](#데이터-모델)
6. [에러 처리](#에러-처리)

---

## 기본 정보

### Base URL
```
http://localhost:8000/api
```

### 응답 형식
- 모든 응답은 JSON 형식
- 필드명은 **snake_case** 사용 (like_count, is_liked, created_at 등)
- 날짜/시간은 ISO 8601 형식 (`2025-01-24T12:00:00Z`)

### 페이징
- 기본: 20개 항목/페이지
- 최대: 100개 항목/페이지
- 파라미터: `?page=1&page_size=20`

**페이징 응답 형식**:
```json
{
  "count": 100,
  "next": "http://localhost:8000/api/grievances/?page=2",
  "previous": null,
  "results": [...]
}
```

---

## 🔐 인증

### JWT 토큰 기반 인증

#### 1. 회원가입
```http
POST /api/auth/register/
Content-Type: application/json
```

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "password2": "securepassword123",
  "first_name": "홍",
  "last_name": "길동",
  "phone_number": "010-1234-5678"
}
```

**응답 (201 Created)**:
```json
{
  "message": "회원가입이 완료되었습니다",
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "first_name": "홍",
    "last_name": "길동",
    "phone_number": "010-1234-5678",
    "profile_image": null,
    "created_at": "2025-01-24T12:00:00Z",
    "updated_at": "2025-01-24T12:00:00Z"
  }
}
```

#### 2. 로그인
```http
POST /api/auth/login/
Content-Type: application/json
```

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**응답 (200 OK)**:
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**토큰 정보**:
- `access`: 1시간 유효 (API 요청 시 사용)
- `refresh`: 7일 유효 (access 토큰 갱신용)

#### 3. 토큰 갱신
```http
POST /api/auth/refresh/
Content-Type: application/json
```

**요청 본문**:
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**응답**:
```json
{
  "access": "new-access-token..."
}
```

#### 4. 현재 유저 정보 조회
```http
GET /api/auth/me/
Authorization: Bearer <access_token>
```

**응답**:
```json
{
  "id": "uuid-string",
  "email": "user@example.com",
  "first_name": "홍",
  "last_name": "길동",
  "phone_number": "010-1234-5678",
  "profile_image": "http://localhost:8000/media/users/profiles/image.jpg",
  "created_at": "2025-01-24T12:00:00Z",
  "updated_at": "2025-01-24T12:00:00Z"
}
```

### 인증 헤더 사용법
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 📝 민원 API

### 1. 민원 목록 조회
```http
GET /api/grievances/
```

**쿼리 파라미터** (선택):
- `page`: 페이지 번호 (기본: 1)
- `page_size`: 페이지당 항목 수 (기본: 20, 최대: 100)
- `status`: 상태 필터 (`pending`, `in_progress`, `resolved`)
- `location`: 지역 필터 (예: "강남구")
- `search`: 제목/내용/지역 검색
- `ordering`: 정렬 (`created_at`, `-created_at`, `like_count`, `-like_count`)

**예시**:
```
GET /api/grievances/?page=1&status=pending&search=도로&ordering=-created_at
```

**응답 (200 OK)**:
```json
{
  "count": 50,
  "next": "http://localhost:8000/api/grievances/?page=2",
  "previous": null,
  "results": [
    {
      "id": "uuid-string",
      "title": "도로 포트홀 신고",
      "content": "강남역 인근 도로에 큰 포트홀이 발생했습니다.",
      "location": "강남구",
      "latitude": 37.4979,
      "longitude": 127.0276,
      "like_count": 15,
      "is_liked": false,
      "images": [
        "http://localhost:8000/media/grievances/images/2025/01/24/image1.jpg",
        "http://localhost:8000/media/grievances/images/2025/01/24/image2.jpg"
      ],
      "created_at": "2025-01-24T12:00:00Z",
      "updated_at": "2025-01-24T12:00:00Z",
      "status": "pending",
      "user_id": "uuid-string",
      "user_name": "홍길동"
    }
  ]
}
```

**필드 설명**:
- `is_liked`: 현재 로그인한 유저의 좋아요 여부 (인증 필요, 비로그인 시 false)
- `images`: 목록에서는 최대 5개만 반환
- `user_id`, `user_name`: 익명 민원의 경우 null

---

### 2. 민원 상세 조회
```http
GET /api/grievances/{id}/
```

**응답 (200 OK)**:
```json
{
  "id": "uuid-string",
  "title": "도로 포트홀 신고",
  "content": "강남역 인근 도로에 큰 포트홀이 발생했습니다. 차량 통행에 위험합니다.",
  "location": "강남구",
  "latitude": 37.4979,
  "longitude": 127.0276,
  "like_count": 15,
  "is_liked": true,
  "images": [
    "http://localhost:8000/media/grievances/images/2025/01/24/image1.jpg",
    "http://localhost:8000/media/grievances/images/2025/01/24/image2.jpg",
    "http://localhost:8000/media/grievances/images/2025/01/24/image3.jpg"
  ],
  "created_at": "2025-01-24T12:00:00Z",
  "updated_at": "2025-01-24T12:00:00Z",
  "status": "pending",
  "user_id": "uuid-string",
  "user_name": "홍길동"
}
```

**차이점**:
- 상세 조회에서는 **모든 이미지** 반환 (목록에서는 최대 5개)

---

### 3. 민원 생성
```http
POST /api/grievances/
Content-Type: multipart/form-data
Authorization: Bearer <access_token> (선택)
```

**폼 데이터**:
```
title: "도로 포트홀 신고"
content: "강남역 인근 도로에 큰 포트홀이 발생했습니다."
latitude: 37.4979
longitude: 127.0276
images: [File1, File2, File3]  // 최대 10개, 각 파일 < 10MB
```

**지원 이미지 형식**: JPG, JPEG, PNG, WEBP

**응답 (201 Created)**:
```json
{
  "id": "uuid-string",
  "title": "도로 포트홀 신고",
  "content": "강남역 인근 도로에 큰 포트홀이 발생했습니다.",
  "location": "강남구",  // 자동 생성 (역지오코딩)
  "latitude": 37.4979,
  "longitude": 127.0276,
  "like_count": 0,
  "is_liked": false,
  "images": [
    "http://localhost:8000/media/grievances/images/2025/01/24/uuid1.jpg",
    "http://localhost:8000/media/grievances/images/2025/01/24/uuid2.jpg"
  ],
  "created_at": "2025-01-24T12:00:00Z",
  "updated_at": "2025-01-24T12:00:00Z",
  "status": "pending",
  "user_id": "uuid-string",  // 로그인 시에만 설정
  "user_name": "홍길동"
}
```

**중요**:
- `location` 필드는 **자동 생성** (Naver Map API 역지오코딩)
- 인증 없이도 생성 가능 (익명 민원)
- 이미지는 선택사항 (없어도 됨)

---

### 4. 민원 수정
```http
PATCH /api/grievances/{id}/
Content-Type: application/json
Authorization: Bearer <access_token>
```

**요청 본문** (수정할 필드만):
```json
{
  "title": "수정된 제목",
  "content": "수정된 내용"
}
```

**권한**: 민원 작성자만 수정 가능

**응답**: 수정된 민원 객체 (상세 조회와 동일)

---

### 5. 민원 삭제
```http
DELETE /api/grievances/{id}/
Authorization: Bearer <access_token>
```

**권한**: 민원 작성자만 삭제 가능

**응답 (204 No Content)**: 본문 없음

---

### 6. 좋아요 토글
```http
PATCH /api/grievances/{id}/like/
Authorization: Bearer <access_token>
```

**요청 본문**: 없음

**응답 (200 OK)**: 업데이트된 민원 객체
```json
{
  "id": "uuid-string",
  "title": "도로 포트홀 신고",
  "like_count": 16,  // 증가 또는 감소
  "is_liked": true,  // 토글됨
  ...
}
```

**동작**:
- 좋아요 안 했으면 → 추가 (like_count 증가, is_liked: true)
- 이미 했으면 → 취소 (like_count 감소, is_liked: false)

---

### 7. 주변 민원 검색
```http
GET /api/grievances/nearby/?lat={latitude}&lng={longitude}&radius={km}
```

**쿼리 파라미터**:
- `lat`: 위도 (필수)
- `lng`: 경도 (필수)
- `radius`: 검색 반경(km, 선택, 기본: 5)

**예시**:
```
GET /api/grievances/nearby/?lat=37.4979&lng=127.0276&radius=3
```

**응답 (200 OK)**:
```json
{
  "count": 12,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": "uuid-string",
      "title": "가장 가까운 민원",
      "distance": 250.5,  // 미터 단위 (annotate됨)
      ...
    },
    {
      "id": "uuid-string2",
      "title": "두 번째로 가까운 민원",
      "distance": 450.2,
      ...
    }
  ]
}
```

**특징**:
- PostGIS 거리 계산 사용 (정확함)
- 거리순 정렬
- 페이징 지원

---

## 👤 유저 API

위의 [인증](#인증) 섹션 참조

---

## 📊 데이터 모델

### GrievanceModel (민원)

```dart
class GrievanceModel {
  final String id;              // UUID
  final String title;           // 제목
  final String content;         // 내용
  final String location;        // 지역명 (예: "강남구")
  final double latitude;        // 위도
  final double longitude;       // 경도
  final int likeCount;          // 좋아요 개수
  final bool isLiked;           // 현재 유저의 좋아요 여부
  final List<String> images;    // 이미지 URL 목록
  final DateTime createdAt;     // 생성일
  final DateTime updatedAt;     // 수정일
  final String status;          // 상태 (pending, in_progress, resolved)
  final String? userId;         // 작성자 ID (익명이면 null)
  final String? userName;       // 작성자 이름 (익명이면 null)
}
```

### UserModel (유저)

```dart
class UserModel {
  final String id;              // UUID
  final String email;           // 이메일
  final String firstName;       // 이름
  final String lastName;        // 성
  final String phoneNumber;     // 전화번호
  final String? profileImage;   // 프로필 이미지 URL (선택)
  final DateTime createdAt;     // 가입일
  final DateTime updatedAt;     // 수정일
}
```

### Status 값

```dart
enum GrievanceStatus {
  pending,      // 대기중
  inProgress,   // 처리중 (in_progress)
  resolved      // 완료
}
```

---

## ⚠️ 에러 처리

### 에러 응답 형식

```json
{
  "error": true,
  "message": "에러 메시지",
  "status_code": 400,
  "details": {
    "field_name": ["상세 에러 메시지"]
  }
}
```

### HTTP 상태 코드

| 코드 | 의미 | 처리 방법 |
|------|------|----------|
| 200 | 성공 | 정상 처리 |
| 201 | 생성 성공 | 리소스 생성됨 |
| 204 | 성공 (응답 없음) | 삭제 완료 등 |
| 400 | 잘못된 요청 | 입력값 검증, 사용자에게 에러 표시 |
| 401 | 인증 실패 | 토큰 만료/없음, 로그인 화면으로 이동 |
| 403 | 권한 없음 | 접근 거부 메시지 표시 |
| 404 | 찾을 수 없음 | 리소스 없음, 목록으로 이동 |
| 500 | 서버 에러 | "일시적 오류" 메시지, 재시도 유도 |

### 일반적인 에러 예시

#### 1. 유효성 검증 실패 (400)
```json
{
  "error": true,
  "message": "Validation Error",
  "status_code": 400,
  "details": {
    "latitude": ["위도는 -90에서 90 사이여야 합니다"],
    "email": ["이메일 형식이 올바르지 않습니다"]
  }
}
```

#### 2. 인증 실패 (401)
```json
{
  "error": true,
  "message": "Authentication credentials were not provided.",
  "status_code": 401
}
```

#### 3. 권한 없음 (403)
```json
{
  "error": true,
  "message": "You do not have permission to perform this action.",
  "status_code": 403
}
```

#### 4. 리소스 없음 (404)
```json
{
  "error": true,
  "message": "Not found.",
  "status_code": 404
}
```

---

## 🔧 개발 팁

### 1. Retrofit 설정 (Flutter)

```dart
@RestApi(baseUrl: "http://localhost:8000/api")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // 민원 목록
  @GET("/grievances/")
  Future<PaginatedResponse<GrievanceModel>> getGrievances(
    @Query("page") int page,
    @Query("status") String? status,
  );

  // 민원 생성 (Multipart)
  @MultiPart()
  @POST("/grievances/")
  Future<GrievanceModel> createGrievance(
    @Part() String title,
    @Part() String content,
    @Part() double latitude,
    @Part() double longitude,
    @Part() List<MultipartFile> images,
  );

  // 좋아요
  @PATCH("/grievances/{id}/like/")
  Future<GrievanceModel> toggleLike(@Path() String id);
}
```

### 2. JWT 인터셉터

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getStoredToken(); // SharedPreferences 등
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 토큰 만료 → 로그인 화면으로
      navigateToLogin();
    }
    super.onError(err, handler);
  }
}
```

### 3. 이미지 업로드

```dart
Future<void> uploadGrievance(List<File> imageFiles) async {
  final multipartFiles = await Future.wait(
    imageFiles.map((file) => MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    )),
  );

  await apiClient.createGrievance(
    title,
    content,
    latitude,
    longitude,
    multipartFiles,
  );
}
```

### 4. 에러 핸들링

```dart
try {
  final grievances = await apiClient.getGrievances(1, null);
  // 성공 처리
} on DioError catch (e) {
  if (e.response != null) {
    final errorData = e.response?.data;
    final message = errorData['message'] ?? '알 수 없는 오류';

    switch (e.response?.statusCode) {
      case 400:
        // 유효성 검증 실패
        showValidationError(errorData['details']);
        break;
      case 401:
        // 인증 실패
        navigateToLogin();
        break;
      case 404:
        // 리소스 없음
        showError('민원을 찾을 수 없습니다');
        break;
      default:
        showError(message);
    }
  } else {
    // 네트워크 오류
    showError('네트워크 연결을 확인해주세요');
  }
}
```

---

## 📌 주요 특징

1. **자동 역지오코딩**: 위도/경도 → 지역명 자동 변환 (Naver Map API)
2. **PostGIS 거리 계산**: 정확한 주변 민원 검색
3. **다중 이미지 업로드**: 최대 10개 이미지 지원
4. **좋아요 토글**: 한 번의 요청으로 추가/취소
5. **익명 민원**: 로그인 없이도 민원 작성 가능
6. **JWT 인증**: Stateless, 모바일 친화적
7. **페이징**: 효율적인 데이터 로딩
8. **필터/검색**: 상태, 지역, 키워드 검색

---

## 🚀 테스트 방법

### 1. cURL 예시

```bash
# 회원가입
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234","password2":"test1234","first_name":"테스트","last_name":"유저"}'

# 로그인
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234"}'

# 민원 목록 조회
curl http://localhost:8000/api/grievances/

# 좋아요 토글
curl -X PATCH http://localhost:8000/api/grievances/{id}/like/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 2. Postman Collection

Postman에서 다음 환경변수 설정:
- `base_url`: `http://localhost:8000/api`
- `access_token`: 로그인 후 받은 토큰

---

## 📞 문의

문제 발생 시:
1. Django 로그 확인: 터미널 출력
2. 데이터베이스 확인: http://localhost:8000/admin
3. API 응답 확인: 개발자 도구 Network 탭

---

**버전**: 1.0
**최종 수정**: 2025-01-24
