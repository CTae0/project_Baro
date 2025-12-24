# 보안 가이드 (Security Guide)

## 📋 개요

BARO 앱은 민감한 정보(API 키, Client ID 등)를 안전하게 관리하기 위해 `.env` 파일을 사용합니다.

## 🔐 환경 변수 관리

### 1. .env 파일 구조

```bash
# frontend/.env (Git에 커밋되지 않음)
NAVER_MAP_CLIENT_ID=your_actual_naver_map_client_id_here
API_BASE_URL_DEV=http://localhost:8000/api
API_BASE_URL_PROD=https://your-production-api.com/api
```

### 2. 보안 원칙

✅ **DO (해야 할 것):**
- `.env.example` 파일을 복사하여 `.env` 파일 생성
- `.env` 파일에 실제 API 키 입력
- `.env` 파일은 절대 Git에 커밋하지 않음 (`.gitignore`에 이미 설정됨)
- 팀원과 공유 시 안전한 채널 사용 (Slack DM, 1Password 등)

❌ **DON'T (하지 말아야 할 것):**
- 네이티브 설정 파일(AndroidManifest.xml, Info.plist)에 직접 API 키 입력
- 소스 코드에 하드코딩
- 공개 저장소에 `.env` 파일 커밋
- 스크린샷이나 공개 채널에 API 키 노출

## 🗺️ 네이버 지도 Client ID 보안

### 구현 방식

BARO 앱은 다음과 같은 방식으로 네이버 지도 Client ID를 안전하게 관리합니다:

#### 1. 네이티브 설정 파일 (플레이스홀더만 포함)

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<meta-data
    android:name="com.naver.maps.map.CLIENT_ID"
    android:value=""/>
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NMFClientId</key>
<string></string>
```

> ⚠️ **중요**: 네이티브 설정 파일에는 빈 값만 유지합니다. 실제 Client ID를 여기에 입력하지 마세요!

#### 2. 런타임 초기화 (main.dart)

앱 시작 시 `.env` 파일에서 Client ID를 읽어 SDK를 초기화합니다:

```dart
// lib/main.dart
await dotenv.load(fileName: '.env');

final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '';

await NaverMapSdk.instance.initialize(
  clientId: naverMapClientId,
);
```

### 장점

1. **Git 안전성**: 네이티브 설정 파일에 민감 정보가 없어 Git에 안전하게 커밋 가능
2. **환경 분리**: 개발/스테이징/프로덕션 환경별로 다른 Client ID 사용 가능
3. **팀 협업**: 각 개발자가 자신의 `.env` 파일로 독립적으로 작업 가능
4. **유출 방지**: 코드 공유 시 API 키 자동 제외

## 🚨 보안 체크리스트

배포 전 다음 사항을 확인하세요:

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는가?
- [ ] Git 히스토리에 `.env` 파일이 커밋되지 않았는가?
- [ ] AndroidManifest.xml과 Info.plist에 실제 Client ID가 하드코딩되지 않았는가?
- [ ] 소스 코드에 다른 API 키가 하드코딩되지 않았는가?
- [ ] 프로덕션 빌드 시 올바른 `.env` 파일을 사용하는가?

## 🔄 환경별 설정

### 개발 환경 (Development)

```bash
# frontend/.env
API_BASE_URL_DEV=http://localhost:8000/api
NAVER_MAP_CLIENT_ID=dev_client_id_here
```

### 프로덕션 환경 (Production)

프로덕션 빌드 시 별도의 `.env.production` 파일을 사용하거나,
CI/CD 파이프라인에서 환경 변수를 주입합니다.

```bash
# CI/CD 예시 (GitHub Actions)
- name: Create .env file
  run: |
    echo "NAVER_MAP_CLIENT_ID=${{ secrets.NAVER_MAP_CLIENT_ID }}" > frontend/.env
    echo "API_BASE_URL_PROD=${{ secrets.API_BASE_URL }}" >> frontend/.env
```

## 📞 API 키 유출 시 대응

만약 실수로 API 키가 공개 저장소에 커밋되었다면:

1. **즉시 키 폐기**: 네이버 클라우드 플랫폼에서 해당 Client ID 삭제
2. **새 키 발급**: 새로운 Client ID 생성
3. **Git 히스토리 정리**: `git filter-branch` 또는 BFG Repo-Cleaner 사용
4. **팀원 공유**: 새로운 Client ID를 안전한 방법으로 팀원에게 공유

## 🛡️ 추가 보안 조치

### 1. Git Guardian 사용

Git에 민감 정보가 커밋되는 것을 자동으로 감지:

```bash
# pre-commit hook 설치
npm install -g @gitguardian/ggshield
ggshield install -m local
```

### 2. flutter_secure_storage 사용

JWT 토큰 등 런타임 민감 정보는 `flutter_secure_storage`에 저장:

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'jwt_token', value: token);
```

## 📚 참고 자료

- [Flutter 환경 변수 관리](https://pub.dev/packages/flutter_dotenv)
- [네이버 지도 SDK 문서](https://navermaps.github.io/android-map-sdk/guide-ko/)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)

---

**BARO** - 보안을 최우선으로 생각합니다. 🔐
