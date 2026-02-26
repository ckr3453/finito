# Finito

[English](README.md)

클라우드 동기화를 지원하는 크로스 플랫폼 TODO 앱. 웹, 데스크탑, 모바일 어디서든 Google 계정으로 할 일을 관리하세요.

**바로 사용하기**: https://finito-f95ea.web.app

## 주요 기능

- 할 일 관리 (제목, 설명, 마감일, 우선순위, 리마인더)
- 카테고리로 할 일 분류
- 검색 및 필터링 (상태, 우선순위, 카테고리)
- 마감일 / 우선순위 / 생성일 기준 정렬
- 드래그 앤 드롭 순서 변경
- 이메일 리마인더 (Cloud Functions + Gmail SMTP)
- 관리자 승인 시스템 (신규 사용자 등록 시 관리자 승인 필요)
- 관리자 대시보드 (사용자 승인/거부, 관리자 권한 부여/해제)
- Google 및 이메일 인증
- 다크 / 라이트 테마
- 반응형 레이아웃 (모바일: 전체 화면, 와이드 스크린: 팝업 다이얼로그)
- 다국어 지원 (한국어 / 영어)
- 오프라인 사용 가능 — 로그인하면 동기화

## 다운로드

데스크탑 설치 파일은 [GitHub Releases](https://github.com/ckr3453/todo-app/releases) 페이지에서 받을 수 있습니다.

| 플랫폼 | 파일 | 참고 |
|--------|------|------|
| Windows | `Finito-Windows-x64.zip` | 압축 해제 후 `finito.exe` 실행 |
| macOS | `Finito-macOS.zip` | 서명되지 않음 — 첫 실행 시 `시스템 설정 > 개인정보 보호 및 보안`에서 "확인 없이 열기" 클릭 필요 |

## 사용 방법

1. https://finito-f95ea.web.app 접속
2. Google 로그인 (또는 비로그인으로 로컬 전용 사용)
3. 할 일 추가 시작

비로그인 시 데이터는 브라우저에 로컬 저장됩니다. 로그인하면 기기 간 동기화가 시작됩니다.

### 지원 플랫폼

| 플랫폼 | 앱 | 위젯 |
|--------|-----|------|
| 웹 | 사용 가능 | - |
| macOS | 사용 가능 | UI만 (데이터 연동은 Apple Developer 계정 필요) |
| Windows | 사용 가능 | - |
| iOS | 사용 가능 | - |
| Android | 사용 가능 | - |

## 아키텍처

### Local-First + Cloud-Synced

UI는 항상 로컬 DB(Drift/SQLite)에서 읽어 즉각 응답합니다. Firestore는 백그라운드에서 동기화합니다.

```
[UI] <--구독--> [Riverpod Providers]
                       |
                  [Repository]
                   /        \
           [Drift DB]    [Firestore]
        (항상 여기서 읽음)  (백그라운드 동기화)
```

### 기술 스택

| 영역 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.38+ (Dart) |
| 상태관리 | Riverpod 2.x (annotation + generator) |
| 로컬 DB | Drift (SQLite ORM) — 웹은 IndexedDB fallback |
| 백엔드 | Firebase (Firestore + Auth + Hosting + Cloud Functions) |
| 이메일 | Cloud Functions + Gmail SMTP (nodemailer) |
| 라우팅 | GoRouter |
| 모델 | Freezed + json_serializable |
| 위젯 연동 | home_widget (WidgetKit) |

### 프로젝트 구조

```
lib/
├── core/              # 상수, 확장함수, 테마, 유틸
├── data/              # 데이터 레이어
│   ├── database/      # Drift DB 테이블, DAO
│   ├── datasources/   # 로컬 + 리모트 데이터소스
│   └── repositories/  # Repository 구현체
├── domain/            # 엔티티 (Freezed), enum, Repository 인터페이스
├── presentation/      # UI 레이어
│   ├── screens/       # 홈, 상세, 편집, 카테고리, 검색, 설정, 인증, 관리자
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # 동기화, 알림, FCM, 위젯, 네트워크, 인증, 사용자
├── routing/           # GoRouter 설정
functions/             # Firebase Cloud Functions (이메일 리마인더)
```

## 개발

### 사전 요구사항

- Flutter 3.38+ (또는 FVM)
- Dart 3.10+
- Firebase CLI
- Node.js 20+ (Cloud Functions용)

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# Firebase 설정 (최초 1회)
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-project-id>

# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

### Cloud Functions 설정

```bash
cd functions
npm install

# Gmail 시크릿 설정 (Blaze 요금제 필요)
firebase functions:secrets:set GMAIL_USER
firebase functions:secrets:set GMAIL_APP_PASSWORD

# 배포
firebase deploy --only functions
```

## 라이선스

MIT 라이선스. 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.
