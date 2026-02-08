# Finito

[English](README.md)

클라우드 동기화와 네이티브 위젯을 지원하는 크로스 플랫폼 TODO 앱.

## 주요 기능

- 할 일 생성/수정/삭제 (제목, 설명, 마감일, 우선순위)
- 카테고리와 태그로 분류
- 검색 및 필터링 (상태, 우선순위, 카테고리)
- 드래그 앤 드롭 정렬
- 다크 모드 지원
- 반응형 레이아웃 (모바일 / 데스크탑)

## 기술 스택

| 영역 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.38+ (Dart) |
| 상태관리 | Riverpod 2.x |
| 로컬 DB | Drift (SQLite ORM) |
| 백엔드 | Firebase (Firestore + Auth) |
| 라우팅 | GoRouter |
| 모델 | Freezed + json_serializable |

## 아키텍처

**Local-First + Cloud-Synced** - UI는 항상 로컬 Drift DB에서 읽고, 온라인 시 백그라운드로 Firestore와 동기화.

```
[UI] <--구독--> [Riverpod Providers]
                       |
                  [Repository]
                   /        \
           [Drift DB]    [Firestore]
        (항상 여기서 읽음)  (온라인 시 동기화)
```

## 프로젝트 구조

```
lib/
├── core/              # 상수, 확장함수, 테마
├── data/              # 데이터 레이어
│   ├── database/      # Drift DB 테이블, DAO
│   └── repositories/  # Repository 구현체
├── domain/            # 엔티티 (Freezed), enum, Repository 인터페이스
├── presentation/      # UI 레이어
│   ├── screens/       # 홈, 상세, 편집, 카테고리, 검색, 설정
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # 동기화, 네트워크 연결
└── routing/           # GoRouter 설정
```

## 지원 플랫폼

- iOS
- Android
- macOS
- Windows

## 시작하기

### 사전 요구사항

- Flutter 3.38+
- Dart 3.10+

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

## 라이선스

개인 사용 목적의 프로젝트입니다.
