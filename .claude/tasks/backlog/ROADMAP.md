# Finito 로드맵

> 이 문서는 Phase별 큰 그림을 정리합니다.
> 개별 태스크 추적은 `INDEX.md`를 참고하세요.

## Phase 1: Local-only TODO App ✅

로컬 전용 TODO 앱 기본 기능 완성.

- 도메인 모델 (Freezed entities, enums)
- Drift DB 테이블 + DAO
- Repository 패턴 (인터페이스 + 로컬 구현)
- Core 유틸리티 + Material 3 테마
- Riverpod Providers
- GoRouter + 하단 네비게이션
- 홈 화면 + Task CRUD UI
- 카테고리/태그/검색 UI
- 설정 화면 (테마 전환)
- CI pipeline + lefthook + 테스트

## Phase 2A: Firebase Auth ✅

이메일/비밀번호 인증. 로그인은 선택사항.

- Firebase 초기화 (실패 시 로컬 전용 fallback)
- AuthService (FirebaseAuth 래퍼)
- Riverpod auth providers
- 로그인/회원가입 화면 (한국어 에러 메시지)
- 설정 화면 계정 섹션
- 단위 테스트 12개
- Firebase 설정 파일 .gitignore 처리

## Phase 2B: Firestore 동기화 ✅

Local-First + Cloud-Synced 아키텍처 완성.

- Firestore DTOs (`data/models/`)
- Remote datasource (`data/datasources/remote/`)
- SyncService (`services/sync_service.dart`)
- ConnectivityService로 온라인/오프라인 감지
- Last-Write-Wins 충돌 해결 (updatedAt 기준)
- Repository를 Local+Remote 통합으로 확장
- 설정 화면 "동기화" 섹션 활성화
- 오프라인 → 온라인 전환 시 자동 동기화

## Phase 3: 소셜 로그인 ✅

Google OAuth 로그인 추가.

- Google Sign-In 패키지 통합
- AuthService에 Google 로그인 메서드 추가 (DI 패턴)
- 로그인/회원가입 화면에 Google 버튼 추가
- signOut 시 Google 세션 정리
- 단위 테스트 15개 (Google 관련 4개 추가)

## Phase 4: Native Widget Bridge ⬜

홈 화면 위젯으로 TODO 빠른 확인.

- home_widget 패키지 통합
- 플랫폼별 네이티브 위젯 구현 (iOS, Android, macOS, Windows)
- 위젯 ↔ 앱 데이터 동기화
- WidgetService (`services/widget_service.dart`)

## Phase 5: 알림 ⬜

FCM 푸시 알림 + 로컬 알림.

- Firebase Cloud Messaging 설정
- 마감일 기반 로컬 알림
- NotificationService (`services/notification_service.dart`)
- 설정 화면 알림 섹션

## 기타 (우선순위 낮음) ⬜

- 익명 로그인
- 이메일 인증 강제
- 계정 삭제
- 드래그앤드롭 정렬 개선
- 다국어 지원 (i18n)
- 앱 아이콘 + 스플래시 스크린
- 스토어 배포 (Google Play, App Store)
