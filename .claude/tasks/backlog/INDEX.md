# Task Backlog

## Archived Phases
- [Phase 1](../archive/phase-1.md) — 로컬 TODO 앱 (9 tasks, 2026-02-08)
- [Phase 2A](../archive/phase-2a.md) — Firebase Auth (1 task, 2026-02-09)
- [Phase 2B](../archive/phase-2b.md) — Firestore 동기화 (12 tasks, 2026-02-10)
- [Infra](../archive/infra.md) — CI, lefthook, tests, git conventions (4 tasks)
- [Phase 3](../archive/phase-3.md) — 소셜 로그인 (1 task, 2026-02-10)

## Completed — Phase 4: Native Widget Bridge

### Phase 4-A: Flutter WidgetService (Dart Layer)
- [x] 4-1. (S) WidgetDataConverter 순수 데이터 변환 로직 (TDD)
- [x] 4-2. (M) WidgetService 인터페이스 + 구현 (TDD) ← 4-1
- [x] 4-3. (S) Background Callback + Entry Point ← 4-2
- [x] 4-4. (S) WidgetService Provider + Repository 통합 ← 4-2
- [x] 4-5. (S) Deep Link URI Scheme + GoRouter 연동

### Phase 4-B: Android (Jetpack Glance)
- [x] 4-6. (S) Android 프로젝트 설정 (Gradle + Manifest) ← 4-2
- [x] 4-7. (S) WidgetDataHelper - SharedPreferences 파싱 (Kotlin) ← 4-6
- [x] 4-8. (M) Small 위젯 (Glance Composable) ← 4-7
- [x] 4-9. (M) Medium 위젯 (Glance + Action Callback) ← 4-8

### Phase 4-C: iOS (WidgetKit + SwiftUI)
- [x] 4-10. (M) iOS WidgetExtension 타겟 + App Group 설정 ← 4-2
- [x] 4-11. (S) iOS Data Model + TimelineProvider (Swift) ← 4-10
- [x] 4-12. (S) iOS Small 위젯 (SwiftUI) ← 4-11
- [x] 4-13. (M) iOS Medium 위젯 (SwiftUI + Intents) ← 4-12

### Phase 4-D: macOS (iOS 코드 공유)
- [x] 4-14. (S) macOS WidgetExtension 타겟 설정 ← 4-11
- [x] 4-15. (S) macOS 위젯 뷰 + 검증 ← 4-14

### Phase 4-E: Windows (Optional)
- [ ] 4-16. (L) Windows Widget Provider — 스킵 (best-effort, 추후 검토)

### Phase 4-F: Integration + Polish
- [x] 4-17. (S) App Lifecycle 위젯 갱신 연동 ← 4-4
- [x] 4-18. (M) E2E 통합 테스트 ← 4-9, 4-13
- [ ] 4-19. (M) 수동 플랫폼 테스트 — 빌드 후 수동 검증 필요

## Completed — Phase 5: 알림 (로컬 리마인더 + FCM)

### Phase 5-A: 데이터 모델 + 마이그레이션
- [x] 5-1. (S) TaskEntity에 `reminderTime` 필드 추가 + Freezed 재빌드
- [x] 5-2. (S) Drift 스키마 v3 마이그레이션 — `reminderTime` 컬럼
- [x] 5-3. (S) Repository + DTO 레이어에 `reminderTime` 반영

### Phase 5-B: 로컬 알림 서비스 (Core)
- [x] 5-4. (S) pubspec.yaml에 패키지 추가
- [x] 5-5. (M) LocalNotificationClient 추상화 + 구현
- [x] 5-6. (M) NotificationService 인터페이스 + 구현 (TDD)
- [x] 5-7. (S) NotificationService Provider + 초기화

### Phase 5-C: FCM 토큰 관리
- [x] 5-8. (M) FcmClient 추상화 + FcmService (TDD)
- [x] 5-9. (S) FCM Provider + auth-gated 초기화

### Phase 5-D: UI
- [x] 5-10. (M) TaskEditor에 리마인더 DateTimePicker 추가
- [x] 5-11. (S) TaskDetail에 리마인더 시간 표시
- [x] 5-12. (S) 알림 탭 → 태스크 상세 화면 네비게이션
- [x] 5-13. (S) Settings에 알림 섹션 추가

### Phase 5-E: 플랫폼 설정 + 통합
- [x] 5-14. (S) Android 알림 권한 설정 (AndroidManifest)
- [x] 5-15. (S) iOS 알림 설정 (Info.plist background modes)
- [x] 5-16. (S) 동기화 후 리마인더 자동 재스케줄
- [x] 5-17. (M) 통합 테스트

## Queue (Phase 6+)

## Independent Tasks
- (S) 앱 아이콘 + 스플래시 스크린
- (M) 다국어 지원
- (M) 스토어 배포

## Recently Completed (latest 5)
