# BARO API 빠른 참조 가이드

프론트엔드 개발자를 위한 핵심 요약

---

## 🔗 엔드포인트 요약

### 인증
```
POST   /api/auth/register/     # 회원가입
POST   /api/auth/login/        # 로그인 (JWT)
POST   /api/auth/refresh/      # 토큰 갱신
GET    /api/auth/me/           # 내 정보 [인증]
```

### 민원
```
GET    /api/grievances/                # 목록
POST   /api/grievances/                # 생성 [multipart]
GET    /api/grievances/{id}/           # 상세
PATCH  /api/grievances/{id}/           # 수정 [인증, 소유자]
DELETE /api/grievances/{id}/           # 삭제 [인증, 소유자]
PATCH  /api/grievances/{id}/like/      # 좋아요 토글 [인증]
GET    /api/grievances/nearby/         # 주변 검색
```

---

## 📦 응답 데이터 구조

### Grievance (민원)
```json
{
  "id": "uuid",
  "title": "제목",
  "content": "내용",
  "location": "강남구",        // 자동 생성
  "latitude": 37.4979,
  "longitude": 127.0276,
  "like_count": 15,
  "is_liked": true,             // 현재 유저 기준
  "images": ["url1", "url2"],   // 최대 5개(목록), 전체(상세)
  "status": "pending",          // pending, in_progress, resolved
  "user_id": "uuid",            // nullable
  "user_name": "홍길동",        // nullable
  "created_at": "2025-01-24T12:00:00Z",
  "updated_at": "2025-01-24T12:00:00Z"
}
```

### User (유저)
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "first_name": "홍",
  "last_name": "길동",
  "phone_number": "010-1234-5678",
  "profile_image": "url",       // nullable
  "created_at": "2025-01-24T12:00:00Z",
  "updated_at": "2025-01-24T12:00:00Z"
}
```

### JWT Tokens
```json
{
  "access": "token...",         // 1시간
  "refresh": "token..."         // 7일
}
```

---

## 🔑 인증 플로우

### 1. 로그인
```
POST /api/auth/login/
{
  "email": "user@example.com",
  "password": "password123"
}

→ { "access": "...", "refresh": "..." }
```

### 2. API 요청 시 헤더
```
Authorization: Bearer <access_token>
```

### 3. 토큰 갱신
```
POST /api/auth/refresh/
{
  "refresh": "<refresh_token>"
}

→ { "access": "new_token..." }
```

### 4. 401 에러 발생 시
→ refresh로 갱신 시도
→ 실패 시 재로그인

---

## 📝 민원 생성 (Multipart)

```http
POST /api/grievances/
Content-Type: multipart/form-data

Form Data:
├─ title: "도로 포트홀 신고"
├─ content: "도로에 구멍이..."
├─ latitude: 37.4979
├─ longitude: 127.0276
├─ images[]: File1.jpg
├─ images[]: File2.jpg
└─ images[]: File3.jpg
```

**Flutter 예시**:
```dart
final multipartFiles = await Future.wait(
  imageFiles.map((f) => MultipartFile.fromFile(f.path))
);

await dio.post(
  '/grievances/',
  data: FormData.fromMap({
    'title': title,
    'content': content,
    'latitude': lat,
    'longitude': lng,
    'images': multipartFiles,
  }),
);
```

---

## 🔍 필터/검색/정렬

### 쿼리 파라미터
```
GET /api/grievances/?page=1&page_size=20&status=pending&search=도로&ordering=-created_at
```

| 파라미터 | 설명 | 예시 |
|---------|------|------|
| `page` | 페이지 번호 | `1` |
| `page_size` | 페이지당 항목 | `20` (최대 100) |
| `status` | 상태 필터 | `pending`, `in_progress`, `resolved` |
| `location` | 지역 필터 | `강남구` |
| `search` | 제목/내용/지역 검색 | `도로` |
| `ordering` | 정렬 | `created_at`, `-created_at`, `like_count` |

---

## 📍 주변 민원 검색

```
GET /api/grievances/nearby/?lat=37.4979&lng=127.0276&radius=5
```

**응답**: 거리순 정렬된 민원 목록 (PostGIS 계산)

---

## ❤️ 좋아요 토글

```http
PATCH /api/grievances/{id}/like/
Authorization: Bearer <token>

→ 좋아요 안 했으면 추가, 했으면 취소
→ 업데이트된 민원 객체 반환
```

---

## ⚠️ 에러 처리

### 에러 응답
```json
{
  "error": true,
  "message": "에러 메시지",
  "status_code": 400,
  "details": {
    "field": ["상세 메시지"]
  }
}
```

### 상태 코드
- **200**: 성공
- **201**: 생성 성공
- **204**: 삭제 성공 (본문 없음)
- **400**: 잘못된 요청 → 입력값 검증
- **401**: 인증 실패 → 토큰 확인/갱신
- **403**: 권한 없음 → 소유자만 가능
- **404**: 없음 → 리소스 찾을 수 없음
- **500**: 서버 오류 → 재시도

---

## 🎯 주요 기능

### ✅ 자동 처리
- **location**: 위도/경도 → 지역명 (Naver Map API)
- **images**: URL 자동 생성
- **like_count**: 실시간 계산
- **is_liked**: 현재 유저 기준 자동 설정

### ✅ 특징
- **익명 민원**: 로그인 없이 생성 가능
- **거리 계산**: PostGIS 정확한 계산
- **페이징**: 20개/페이지 (최대 100)
- **이미지**: 최대 10개, JPG/PNG/WEBP

---

## 🧪 테스트

### cURL
```bash
# 로그인
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test1234"}'

# 민원 목록
curl http://localhost:8000/api/grievances/

# 좋아요 (토큰 필요)
curl -X PATCH http://localhost:8000/api/grievances/{id}/like/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 관리자 페이지
```
http://localhost:8000/admin
admin@baro.com / admin1234
```

---

## 📚 전체 문서

자세한 내용은 `API_DOCUMENTATION.md` 참조

---

## 💡 Flutter Dio 설정

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:8000/api',
  headers: {'Content-Type': 'application/json'},
));

// 인터셉터 추가
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) {
    if (error.response?.statusCode == 401) {
      // 토큰 갱신 또는 로그아웃
    }
    return handler.next(error);
  },
));
```

---

**Base URL**: `http://localhost:8000/api`
**인증**: `Authorization: Bearer <token>`
**응답 형식**: JSON (snake_case)
