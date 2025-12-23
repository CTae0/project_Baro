# BARO (바로) - 시민 민원 해결 플랫폼

대학생 창업팀을 위한 시민 민원 해결 플랫폼 MVP 프로젝트입니다.

## 📱 프로젝트 개요

**BARO**는 시민이 위치 기반으로 민원을 제보하고, 담당 정치인이 해결하는 경쟁 플랫폼입니다.

### 핵심 원칙 (Privacy-First)

1. **민원 작성 시**: 네이버 지도로 정확한 위치 확인 및 핀 설정
2. **민원 조회 시**: 리스트 형태로만 제공 (Privacy 보호 및 속도 향상)
3. **백엔드 연동**: Django REST API와 통신

## 🛠 기술 스택

### Framework & Language
- **Flutter** (Latest version)
- **Dart**

### 주요 패키지
- **State Management**: Riverpod
- **Networking**: Dio + Retrofit
- **Routing**: GoRouter
- **Map**: flutter_naver_map (네이버 지도 SDK)
- **Location**: Geolocator
- **Image**: image_picker
- **Storage**: flutter_secure_storage, shared_preferences

## 📁 폴더 구조 (Feature-based)

```
lib/
├── main.dart
├── core/
│   ├── constants/          # 앱 상수
│   ├── theme/             # 테마 설정
│   ├── router/            # 라우팅 설정
│   ├── network/           # API 클라이언트
│   └── utils/             # 유틸리티 함수
├── features/
│   ├── grievance/         # 민원 기능
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── data_sources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── map/               # 지도 기능
│   └── auth/              # 인증 기능
└── assets/
    ├── images/
    └── icons/
```

## 🚀 시작하기

### 1. 사전 요구사항

- Flutter SDK (3.10.4 이상)
- Dart SDK (3.10.4 이상)
- Android Studio / Xcode (모바일 개발용)
- 네이버 클라우드 플랫폼 계정 (지도 API용)

### 2. 네이버 지도 API 설정

#### 네이버 클라우드 플랫폼에서 Client ID 발급

1. [네이버 클라우드 플랫폼](https://www.ncloud.com/) 접속
2. **Console > Services > AI·NAVER API > AI·NAVER API**
3. **Application 등록** 클릭
4. **Mobile Dynamic Map** 선택
5. 앱 정보 입력:
   - **Android 앱 패키지명**: `com.baro.baro`
   - **iOS Bundle ID**: `com.baro.baro`
6. **Client ID** 복사

#### Android 설정

`android/app/src/main/AndroidManifest.xml` 파일에서 `YOUR_NAVER_MAP_CLIENT_ID_HERE`를 발급받은 Client ID로 교체:

```xml
<meta-data
    android:name="com.naver.maps.map.CLIENT_ID"
    android:value="YOUR_NAVER_MAP_CLIENT_ID_HERE"/>
```

#### iOS 설정

`ios/Runner/Info.plist` 파일에서 `YOUR_NAVER_MAP_CLIENT_ID_HERE`를 발급받은 Client ID로 교체:

```xml
<key>NMFClientId</key>
<string>YOUR_NAVER_MAP_CLIENT_ID_HERE</string>
```

### 3. 의존성 설치

```bash
flutter pub get
```

### 4. 앱 실행

```bash
flutter run
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

1. Client ID가 올바르게 설정되었는지 확인
2. AndroidManifest.xml 및 Info.plist의 패키지명/Bundle ID 확인
3. 네이버 클라우드 플랫폼에서 앱 등록 정보 재확인

## 📄 라이선스

이 프로젝트는 대학생 창업 프로젝트로, 상업적 용도로 사용됩니다.

---

**BARO** - 시민의 목소리를 바로 전달합니다. 🚀
