# BARO (바로) - 시민 민원 해결 플랫폼


## 📱 프로젝트 개요

**BARO**는 시민이 위치 기반으로 민원을 제보하고, 담당 정치인이 해결하는 경쟁 플랫폼입니다.

### 핵심 원칙 (Privacy-First)

1. **민원 작성 시**: 네이버 지도로 정확한 위치 확인 및 핀 설정
2. **민원 조회 시**: 리스트 형태로만 제공 (Privacy 보호 및 속도 향상)
3. **백엔드 연동**: Django REST API와 통신

## 🛠 기술 스택

### Frontend (Flutter)
- **Framework**: Flutter 3.38.5 / Dart 3.10.4
- **State Management**: Riverpod (code generation)
- **Networking**: Dio + Retrofit
- **Routing**: GoRouter
- **Map**: flutter_naver_map (네이버 지도 SDK)
- **Location**: Geolocator
- **Image**: image_picker
- **Storage**: flutter_secure_storage, shared_preferences
- **Architecture**: Clean Architecture (Domain/Data/Presentation)

### Backend (Django)
- **Framework**: Django + Django REST Framework
- **Authentication**: JWT (JSON Web Token)
- **Database**: PostgreSQL (production) / SQLite (development)
- **Media Storage**: Local storage (development) / S3 (production)

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

## 🔑 주요 기능 구현 계획

### Phase 1: MVP (현재)
- ✅ 프로젝트 초기 세팅
- ✅ 폴더 구조 구성
- ✅ 네이버 지도 SDK 설정
- ✅ 기본 라우팅 구성
- ✅ 테마 설정
- 🔲 민원 리스트 화면
- 🔲 민원 작성 화면 (지도 연동)
- 🔲 민원 상세 화면

### Phase 2: 핵심 기능
- 🔲 Django 백엔드 연동
- 🔲 사진 촬영 및 업로드
- 🔲 GPS 위치 수집
- 🔲 네이버 지도 위치 선택
- 🔲 사용자 인증 (JWT)

### Phase 3: 확장 기능
- 🔲 푸시 알림
- 🔲 민원 진행 상황 추적
- 🔲 정치인 대시보드
- 🔲 통계 및 분석

## 🔐 보안 고려사항

- **민감 정보 보호**: `flutter_secure_storage` 사용
- **API 토큰 관리**: Dio Interceptor를 통한 자동 토큰 주입
- **이미지 압축**: 업로드 전 이미지 최적화
- **권한 관리**: 위치, 카메라 권한 최소화 요청

## 📝 코딩 규칙

1. **Dart 스타일 가이드** 준수
2. **feature-first** 아키텍처 사용
3. **Riverpod**으로 상태 관리
4. **freezed**로 불변 모델 생성 (향후)
5. **dio + retrofit**으로 API 통신
6. **한글 주석** 작성 (팀원 간 이해도 향상)

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

## 📄 라이선스

이 프로젝트는 대학생 창업 프로젝트로, 상업적 용도로 사용됩니다.

---

**BARO** - 시민의 목소리를 바로 전달합니다. 🚀
