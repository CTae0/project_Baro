# BARO (바로) - 시민 민원 해결 플랫폼

> **"우리 동네 문제, 바로 해결합니다"**
> 시민이 직접 제보하고, 정치인이 경쟁적으로 해결하는 투명한 민원 플랫폼

---

## 💡 BARO란?

**BARO**는 시민과 정치인을 직접 연결하는 **위치 기반 민원 해결 플랫폼**입니다.

### 🎯 우리가 해결하려는 문제

현재 민원 처리 시스템의 문제점:
- **불투명한 처리 과정**: 내가 낸 민원이 어떻게 처리되는지 알 수 없음
- **느린 응답 속도**: 몇 주, 몇 달이 걸려도 답변이 없는 경우가 많음
- **책임 소재 불명확**: 누가 담당하는지, 왜 해결이 안 되는지 모름
- **정치인과의 단절**: 우리 지역 정치인이 실제로 무슨 일을 하는지 모름

### ✨ BARO의 해결 방법

1. **투명한 공개**: 모든 민원이 공개되어 누구나 볼 수 있습니다
2. **위치 기반**: 내 주변의 문제를 지도에서 한눈에 확인할 수 있습니다
3. **경쟁 구조**: 여러 정치인이 같은 민원을 보고 경쟁적으로 해결합니다
4. **좋아요 시스템**: 시민들이 중요하다고 생각하는 민원에 좋아요를 눌러 우선순위를 정합니다
5. **실시간 추적**: 민원이 어떻게 처리되고 있는지 실시간으로 확인할 수 있습니다

---

## 🎬 사용 시나리오

### 시민의 경우

1. **문제 발견**: 집 앞 도로에 큰 구멍(포트홀)을 발견했습니다
2. **사진 촬영**: 스마트폰으로 문제 상황을 촬영합니다
3. **민원 등록**: BARO 앱에서 위치를 선택하고 사진과 설명을 올립니다
4. **공개 및 공유**: 민원이 자동으로 공개되고, 같은 지역 주민들이 볼 수 있습니다
5. **진행 상황 확인**: 어떤 정치인이 관심을 보이는지, 언제 해결되는지 추적합니다

### 정치인의 경우

1. **민원 확인**: 자신의 지역구에서 올라온 민원들을 확인합니다
2. **우선순위 파악**: 좋아요가 많은 민원부터 확인합니다
3. **해결 약속**: "이 문제를 해결하겠습니다" 선언하고 담당자를 지정합니다
4. **진행 보고**: 처리 과정을 단계별로 업데이트합니다
5. **결과 공유**: 해결 완료 사진과 함께 완료 보고를 올립니다

---

## 🏗️ 핵심 기능

### 1️⃣ 위치 기반 민원 제보
- **네이버 지도 연동**: 정확한 위치에 민원을 등록할 수 있습니다
- **사진 업로드**: 현장 상황을 사진으로 증빙할 수 있습니다
- **카테고리 분류**: 도로, 환경, 안전, 시설 등 문제 유형을 분류합니다

### 2️⃣ 투명한 민원 목록
- **지역별 조회**: 내 동네, 우리 구, 우리 시의 민원을 한눈에 볼 수 있습니다
- **상태별 필터**: 접수됨, 처리중, 완료, 보류 등 진행 상태별로 확인 가능합니다
- **좋아요 순 정렬**: 시민들이 중요하다고 생각하는 민원을 우선 확인할 수 있습니다

### 3️⃣ 실시간 진행 추적
- **타임라인 뷰**: 민원이 어떻게 진행되고 있는지 시간순으로 확인합니다
- **알림 기능**: 내가 올린 민원이나 좋아요한 민원에 업데이트가 있으면 알림을 받습니다
- **댓글 소통**: 시민과 정치인이 직접 소통할 수 있습니다

### 4️⃣ 정치인 평가 시스템
- **해결률 표시**: 각 정치인이 얼마나 많은 민원을 해결했는지 확인할 수 있습니다
- **반응 속도**: 민원에 얼마나 빨리 응답하는지 평균 시간을 볼 수 있습니다
- **시민 만족도**: 해결된 민원에 대한 시민들의 평가를 확인할 수 있습니다

---

## 🔒 개인정보 보호

BARO는 **프라이버시를 최우선**으로 생각합니다:

### 선택적 익명성
- **민원 작성**: 실명 또는 익명으로 선택 가능합니다
- **위치 정보**: 정확한 주소가 아닌 대략적인 위치만 공개됩니다
- **개인정보**: 이름, 연락처 등은 절대 공개되지 않습니다

### 안전한 데이터 관리
- **암호화 저장**: 모든 개인정보는 암호화되어 저장됩니다
- **최소 수집**: 서비스에 꼭 필요한 정보만 수집합니다
- **투명한 정책**: 어떤 정보를 어떻게 사용하는지 명확히 공개합니다

---

## 🛠 기술 스택 및 시스템 구조

### 📱 프론트엔드 (사용자가 보는 앱)

**Flutter**를 사용하여 **Android와 iOS 모두 지원하는** 크로스 플랫폼 앱을 개발합니다.

#### 주요 기술 및 역할

| 기술 | 용도 | 일반인 설명 |
|------|------|-------------|
| **Flutter 3.38.5** | 앱 프레임워크 | Google이 만든 모바일 앱 개발 도구. 한번 개발하면 Android와 iOS 모두 사용 가능 |
| **Riverpod** | 상태 관리 | 앱의 데이터 흐름을 관리. 예: 민원 목록, 로그인 상태 등 |
| **네이버 지도 SDK** | 지도 표시 | 민원 위치를 지도에 표시하고, 사용자가 위치를 선택할 수 있게 함 |
| **Dio + Retrofit** | 서버 통신 | Django 백엔드와 데이터를 주고받음 (민원 등록, 조회 등) |
| **GoRouter** | 화면 이동 | 앱 내에서 페이지 간 이동을 관리 (홈 → 민원 작성 → 상세보기) |
| **Image Picker** | 사진 선택 | 갤러리나 카메라에서 사진을 가져옴 |
| **Geolocator** | 위치 추적 | GPS를 사용해 현재 위치를 파악 |

#### Clean Architecture (깔끔한 설계)

코드를 **3개 레이어로 분리**하여 유지보수가 쉽도록 구조화:

```
📱 Presentation (화면)
   ↓ 사용자가 버튼 클릭
💼 Domain (비즈니스 로직)
   ↓ 데이터 요청
📊 Data (데이터 처리)
   ↓ API 호출
🌐 Django Backend
```

---

### 🖥️ 백엔드 (서버)

**Django**를 사용하여 **RESTful API 서버**를 구축합니다.

#### 주요 기술 및 역할

| 기술 | 용도 | 일반인 설명 |
|------|------|-------------|
| **Django** | 웹 프레임워크 | Python 기반의 안정적이고 빠른 웹 서버 개발 도구 |
| **Django REST Framework** | API 제작 | 앱과 서버 간 데이터 교환을 위한 API 개발 도구 |
| **PostgreSQL + PostGIS** | 데이터베이스 | 민원, 사용자 정보 저장. PostGIS로 지리 정보(위도, 경도) 처리 |
| **JWT** | 인증 시스템 | 로그인 시 토큰을 발급하여 사용자를 안전하게 인증 |
| **Kakao/Naver OAuth** | 소셜 로그인 | 카카오/네이버 계정으로 간편하게 로그인 |

#### 주요 기능 구현

1. **역지오코딩 (Reverse Geocoding)**
   - 위도/경도 → 주소 변환
   - 예: `(37.5665, 126.9780)` → "서울특별시 중구 세종대로"
   - 네이버 지오코딩 API 활용

2. **공간 검색 (Spatial Search)**
   - PostGIS의 지리 기능 활용
   - "내 주변 3km 이내 민원 찾기" 같은 기능 구현

3. **이미지 처리**
   - 업로드된 사진 자동 압축 및 리사이징
   - AWS S3 또는 로컬 스토리지에 저장

4. **실시간 알림**
   - 민원 업데이트 시 FCM(Firebase Cloud Messaging)으로 푸시 알림 전송

---

### 🔄 시스템 동작 흐름

#### 1. 민원 등록 과정

```
👤 사용자
   ↓ ① 사진 촬영 + 위치 선택
📱 Flutter 앱
   ↓ ② JSON + 이미지 파일을 HTTP POST로 전송
🌐 Django API (/api/grievances/)
   ↓ ③ 이미지 저장 + 역지오코딩
💾 PostgreSQL
   ↓ ④ 저장 완료 응답
📱 Flutter 앱
   ↓ ⑤ "민원이 등록되었습니다" 표시
👤 사용자
```

#### 2. 민원 목록 조회

```
👤 사용자
   ↓ ① 앱 열기
📱 Flutter 앱
   ↓ ② GET /api/grievances/ 요청
🌐 Django API
   ↓ ③ 현재 위치 기준 주변 민원 검색 (PostGIS)
💾 PostgreSQL
   ↓ ④ JSON 형태로 민원 목록 반환
📱 Flutter 앱
   ↓ ⑤ 리스트 형태로 화면에 표시
👤 사용자
```

#### 3. 좋아요 기능

```
👤 사용자
   ↓ ① 좋아요 버튼 클릭
📱 Flutter 앱
   ↓ ② PATCH /api/grievances/{id}/like/
🌐 Django API
   ↓ ③ 토글 처리 (좋아요 ↔ 취소)
💾 PostgreSQL
   ↓ ④ 좋아요 수 업데이트
📱 Flutter 앱
   ↓ ⑤ 화면 갱신
👤 사용자
```

---

### 🔐 보안 및 인증 시스템

#### JWT 기반 인증 흐름

```
👤 카카오/네이버 로그인
   ↓
🌐 Django: OAuth 토큰 검증
   ↓
🔑 JWT Access Token 발급 (30분 유효)
🔄 JWT Refresh Token 발급 (2주 유효)
   ↓
📱 Flutter: Secure Storage에 저장
   ↓
📱 모든 API 요청 시 Header에 토큰 자동 포함
   ↓
🌐 Django: 토큰 검증 후 요청 처리
```

#### 데이터 암호화

- **전송 중**: HTTPS (TLS 1.3)
- **저장 시**:
  - 토큰: Flutter Secure Storage (AES 암호화)
  - 비밀번호: Django Argon2 해시
  - DB: PostgreSQL 암호화 컬럼

---

## 📁 프로젝트 구조

```
d:\Proejct_BARO/
├── frontend/                   # Flutter 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── constants/     # 앱 상수
│   │   │   ├── theme/         # 테마 설정
│   │   │   ├── router/        # 라우팅 설정
│   │   │   ├── network/       # API 클라이언트 (Dio)
│   │   │   ├── error/         # Failure & Exception
│   │   │   └── utils/         # 유틸리티 함수
│   │   └── features/
│   │       ├── grievance/     # 민원 기능 (Clean Architecture)
│   │       │   ├── data/
│   │       │   │   ├── models/
│   │       │   │   ├── repositories/
│   │       │   │   └── datasources/
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   ├── repositories/
│   │       │   │   └── usecases/
│   │       │   └── presentation/
│   │       │       ├── pages/
│   │       │       ├── widgets/
│   │       │       └── providers/
│   │       ├── map/           # 지도 기능
│   │       └── auth/          # 인증 기능
│   ├── assets/
│   │   ├── images/
│   │   └── icons/
│   ├── android/               # Android 설정
│   ├── ios/                   # iOS 설정
│   ├── pubspec.yaml
│   └── .env                   # 환경 변수 (Git 미포함)
│
├── backend/                   # Django API 서버
│   ├── manage.py
│   ├── config/                # Django 설정
│   ├── apps/
│   │   ├── grievance/        # 민원 앱
│   │   ├── users/            # 사용자 앱
│   │   └── core/             # 공통 기능
│   ├── requirements.txt
│   └── .env                   # 환경 변수 (Git 미포함)
│
├── .git/                      # Git 저장소
├── .gitignore
└── README.md
```

## 🚀 시작하기

### 1. 사전 요구사항

**Frontend:**
- Flutter SDK (3.38.5 이상)
- Dart SDK (3.10.4 이상)
- Android Studio / Xcode (모바일 개발용)
- 네이버 클라우드 플랫폼 계정 (지도 API용)

**Backend:**
- Python 3.10+
- pip / pipenv
- PostgreSQL (선택사항, 개발 시 SQLite 사용 가능)

### 2. Frontend 설정

#### 2-1. 환경 변수 설정 (.env)

**중요**: 보안을 위해 민감한 정보는 `.env` 파일에 저장합니다.

1. `.env.example` 파일을 복사하여 `.env` 파일 생성:
   ```bash
   cd frontend
   cp .env.example .env
   ```

2. `.env` 파일을 열고 API 정보를 입력:
   ```bash
   # 네이버 지도 API
   NAVER_MAP_CLIENT_ID=your_naver_map_client_id_here

   # Django 백엔드 API (로컬 개발)
   API_BASE_URL_DEV=http://localhost:8000/api

   # Django 백엔드 API (프로덕션)
   API_BASE_URL_PROD=https://your-production-api.com/api
   ```

### 3. 네이버 지도 API Client ID 발급

1. [네이버 클라우드 플랫폼](https://www.ncloud.com/) 접속
2. **Console > Services > AI·NAVER API > AI·NAVER API**
3. **Application 등록** 클릭
4. **Mobile Dynamic Map** 선택
5. 앱 정보 입력:
   - **Android 앱 패키지명**: `com.baro.baro`
   - **iOS Bundle ID**: `com.baro.baro`
6. **Client ID** 복사
7. 복사한 Client ID를 `.env` 파일의 `NAVER_MAP_CLIENT_ID`에 입력

#### 2-2. 의존성 설치

```bash
cd frontend
flutter pub get
```

#### 2-3. 앱 실행

```bash
cd frontend
flutter run
```

### 3. Backend 설정 (Django)

#### 3-1. 가상환경 생성 및 활성화

```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate
```

#### 3-2. 패키지 설치

```bash
pip install -r requirements.txt
```

#### 3-3. 환경 변수 설정

```bash
cp .env.example .env
# .env 파일을 열고 데이터베이스 설정 등 입력
```

#### 3-4. 데이터베이스 마이그레이션

```bash
python manage.py migrate
```

#### 3-5. 개발 서버 실행

```bash
python manage.py runserver
# 서버가 http://localhost:8000 에서 실행됩니다
```

## 🗺️ 개발 로드맵

### Phase 1: 기본 민원 시스템 (2025년 1월 - 완료)

#### ✅ Backend (Django)
- ✅ Django REST API 프로젝트 초기 설정
- ✅ PostgreSQL + PostGIS 데이터베이스 연동
- ✅ Grievance 모델 구현 (제목, 내용, 위도, 경도, 상태)
- ✅ Like 모델 구현 (좋아요 기능)
- ✅ GrievanceImage 모델 구현 (다중 이미지 지원)
- ✅ CustomUser 모델 구현 (확장 가능한 사용자 모델)
- ✅ Serializers 구현 (List/Detail/Create 분리)
- ✅ ViewSet 구현 (CRUD + 좋아요 + 주변 검색)
- ✅ 역지오코딩 서비스 구현 (네이버 API)
- ✅ CORS 설정 (Flutter 앱 연동)
- ✅ API 엔드포인트:
  - `GET /api/grievances/` - 민원 목록
  - `GET /api/grievances/{id}/` - 민원 상세
  - `POST /api/grievances/` - 민원 생성 (JSON/Multipart 지원)
  - `PATCH /api/grievances/{id}/like/` - 좋아요 토글
  - `DELETE /api/grievances/{id}/` - 민원 삭제
  - `GET /api/grievances/nearby/` - 주변 민원 검색

#### ✅ Frontend (Flutter)
- ✅ Flutter 프로젝트 초기 설정 (Clean Architecture)
- ✅ 네이버 지도 SDK 연동 (`flutter_naver_map`)
- ✅ Riverpod 상태 관리 설정 (code generation)
- ✅ GoRouter 라우팅 설정
- ✅ Dio + Retrofit HTTP 클라이언트 구현
- ✅ 민원 도메인 레이어:
  - Entity, Repository 인터페이스, UseCases
- ✅ 민원 데이터 레이어:
  - Model (JSON 직렬화), Repository 구현, Remote DataSource
- ✅ 민원 프레젠테이션 레이어:
  - ✅ `GrievanceListPage` - 민원 목록 화면
  - ✅ `GrievanceDetailPage` - 민원 상세 화면
  - ✅ `GrievanceCreatePage` - 민원 작성 화면 (지도 연동)
  - ✅ `GrievanceCard` - 민원 카드 위젯
  - ✅ Providers (List, Detail, Create UseCases)
- ✅ 네이버 지도 위젯 구현 (위치 선택 기능)
- ✅ 테마 설정 (Material Design 3)

#### 🔧 완료된 주요 기능
- ✅ 민원 조회 및 상세보기
- ✅ 민원 작성 (위치 기반)
- ✅ 좋아요 기능
- ✅ JSON 기반 API 통신 (이미지 없을 때)
- ✅ 에러 핸들링 (Failure 패턴)

---

### Phase 2: 이미지 업로드 및 인증 (2025년 2월 - 진행 중)

#### 🚧 진행 중인 작업
- ✅ `image_picker` 패키지 설치 완료
- 🚧 사진 촬영 및 갤러리 선택 UI 구현
- 🚧 Multipart/form-data 이미지 업로드
- 🚧 이미지 압축 및 최적화
- 🔲 이미지 갤러리 뷰 (Carousel)

#### 📋 예정된 작업 (인증 시스템)
- 🔲 Kakao OAuth 소셜 로그인
- 🔲 Naver OAuth 소셜 로그인
- 🔲 JWT 토큰 기반 인증 시스템
- 🔲 Flutter Secure Storage 토큰 저장
- 🔲 Dio Interceptor 자동 토큰 주입
- 🔲 사용자 프로필 관리
- 🔲 프로필 사진 설정

### Phase 3: 고급 기능 (2025년 3월)
📅 **계획 중**
- 푸시 알림 (Firebase Cloud Messaging)
- 민원 진행 상황 타임라인
- 댓글 및 대화 기능
- 실시간 업데이트 (WebSocket)
- 주변 민원 지도 뷰

### Phase 4: 정치인 기능 (2025년 4월)
📅 **계획 중**
- 정치인 전용 대시보드
- 민원 할당 및 관리
- 처리 현황 리포트
- 통계 및 분석
- 시민 만족도 평가

### Phase 5: 고도화 (2025년 5월 이후)
📅 **장기 계획**
- AI 기반 민원 자동 분류
- 중복 민원 자동 탐지
- 예상 처리 시간 예측
- 다국어 지원 (영어, 중국어)
- 웹 버전 (React/Next.js)

---

## 🎯 핵심 성능 지표 (KPI)

### 시민 관점
- **민원 등록**: 3번의 터치로 완료 (사진, 위치, 제출)
- **응답 속도**: API 평균 응답 200ms 이하
- **앱 크기**: 50MB 이하 (APK/IPA)
- **배터리 소모**: 1시간 사용 시 5% 이하

### 정치인 관점
- **민원 할당**: 5초 이내 자동 지역구 매칭
- **알림 전달**: 실시간 (3초 이내)
- **처리율 목표**: 월 90% 이상 응답

### 시스템 성능
- **동시 접속**: 10,000명 지원
- **데이터베이스**: 1,000,000건의 민원 처리
- **이미지 저장**: 월 10TB까지 확장 가능

---

## 🐛 문제 해결

### 네이버 지도가 표시되지 않는 경우

1. `.env` 파일에 `NAVER_MAP_CLIENT_ID`가 올바르게 설정되었는지 확인
2. 네이버 클라우드 플랫폼에서 앱 등록 정보 재확인 (패키지명/Bundle ID)
3. `flutter clean` 후 재빌드 시도

### .env 파일 관련 오류

만약 `.env` 파일을 찾을 수 없다는 오류가 발생하면:
```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# .env 파일에 실제 Client ID 입력 후
flutter pub get
flutter run
```

## ❓ 자주 묻는 질문 (FAQ)

### Q1. BARO는 무료인가요?
**A.** 네, 시민들에게는 완전 무료입니다. 정치인 대시보드는 월 구독 모델로 제공됩니다.

### Q2. 익명으로 민원을 올릴 수 있나요?
**A.** 네, 로그인 없이도 민원을 올릴 수 있습니다. 단, 진행 상황 알림을 받으려면 로그인이 필요합니다.

### Q3. 내 개인정보는 안전한가요?
**A.** 모든 개인정보는 암호화되어 저장되며, 정확한 주소는 공개되지 않습니다. 대략적인 위치(동 단위)만 표시됩니다.

### Q4. 어떤 종류의 민원을 올릴 수 있나요?
**A.** 도로, 환경, 안전, 시설 등 지역사회와 관련된 모든 문제를 제보할 수 있습니다. 개인적인 민원은 관할 기관에 직접 문의해주세요.

### Q5. 민원이 해결되는 데 얼마나 걸리나요?
**A.** 민원의 종류와 복잡도에 따라 다르지만, 평균적으로 2-4주 정도 소요됩니다. 긴급한 안전 문제는 우선 처리됩니다.

### Q6. 정치인은 어떻게 가입하나요?
**A.** 공식 이메일을 통해 신청하시면 신분 확인 후 승인됩니다. 자세한 내용은 문의해주세요.

### Q7. Android와 iOS 모두 지원하나요?
**A.** 네, Flutter로 개발하여 Android와 iOS 모두 완벽하게 지원합니다.

### Q8. 오프라인에서도 사용할 수 있나요?
**A.** 민원 조회는 오프라인에서도 캐시된 데이터로 가능하지만, 등록과 업데이트는 인터넷 연결이 필요합니다.

---

## 🤝 기여 및 개발 참여

BARO는 오픈소스 프로젝트는 아니지만, 버그 리포트와 기능 제안은 환영합니다!

### 버그 리포트
- 이슈 템플릿에 따라 상세히 작성해주세요
- 재현 가능한 단계와 스크린샷 포함
- 디바이스 정보 및 OS 버전 명시

### 기능 제안
- 어떤 문제를 해결하는지 설명
- 예상되는 사용 시나리오 제시
- UI/UX 목업이 있다면 더욱 좋습니다

---

## 📞 문의 및 지원

### 이메일
- **일반 문의**: contact@baro.com (예시)
- **기술 지원**: dev@baro.com (예시)
- **사업 제휴**: business@baro.com (예시)

### 소셜 미디어
- **Instagram**: @baro_official (예시)
- **Twitter**: @baro_kr (예시)
- **Facebook**: facebook.com/baro (예시)

### 개발자
- **GitHub**: 본 프로젝트
- **Discord**: 개발자 커뮤니티 (추후 공개)

---

## 📄 라이선스

이 프로젝트는 대학생 창업 프로젝트로, 상업적 용도로 사용됩니다.

**Copyright © 2025 BARO Team. All rights reserved.**

---

## 🌟 팀 소개

BARO는 시민과 정치인을 연결하여 더 나은 지역사회를 만들고자 하는 대학생 창업 팀입니다.

### 우리의 미션
> "투명하고 효율적인 민원 해결로 시민과 정치인의 신뢰를 회복합니다"

### 우리의 비전
> "대한민국의 모든 민원이 BARO를 통해 해결되는 그날까지"

---

<div align="center">

**BARO (바로)** - 시민의 목소리를 바로 전달합니다 🚀

Made with ❤️ in South Korea

[홈페이지](https://baro.com) | [앱 다운로드](https://play.google.com) | [문의하기](mailto:contact@baro.com)

</div>
