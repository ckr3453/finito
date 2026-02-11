# Phase 4: Native Widget Bridge (2026-02-10)

## Phase 4-A: Flutter WidgetService (Dart Layer)
- [x] 4-1. (S) WidgetDataConverter 순수 데이터 변환 로직 (TDD)
- [x] 4-2. (M) WidgetService 인터페이스 + 구현 (TDD) ← 4-1
- [x] 4-3. (S) Background Callback + Entry Point ← 4-2
- [x] 4-4. (S) WidgetService Provider + Repository 통합 ← 4-2
- [x] 4-5. (S) Deep Link URI Scheme + GoRouter 연동

## Phase 4-B: Android (Jetpack Glance)
- [x] 4-6. (S) Android 프로젝트 설정 (Gradle + Manifest) ← 4-2
- [x] 4-7. (S) WidgetDataHelper - SharedPreferences 파싱 (Kotlin) ← 4-6
- [x] 4-8. (M) Small 위젯 (Glance Composable) ← 4-7
- [x] 4-9. (M) Medium 위젯 (Glance + Action Callback) ← 4-8

## Phase 4-C: iOS (WidgetKit + SwiftUI)
- [x] 4-10. (M) iOS WidgetExtension 타겟 + App Group 설정 ← 4-2
- [x] 4-11. (S) iOS Data Model + TimelineProvider (Swift) ← 4-10
- [x] 4-12. (S) iOS Small 위젯 (SwiftUI) ← 4-11
- [x] 4-13. (M) iOS Medium 위젯 (SwiftUI + Intents) ← 4-12

## Phase 4-D: macOS (iOS 코드 공유)
- [x] 4-14. (S) macOS WidgetExtension 타겟 설정 ← 4-11
- [x] 4-15. (S) macOS 위젯 뷰 + 검증 ← 4-14

## Phase 4-E: Windows (Optional)
- [ ] 4-16. (L) Windows Widget Provider — 스킵 (best-effort, 추후 검토)

## Phase 4-F: Integration + Polish
- [x] 4-17. (S) App Lifecycle 위젯 갱신 연동 ← 4-4
- [x] 4-18. (M) E2E 통합 테스트 ← 4-9, 4-13
- [ ] 4-19. (M) 수동 플랫폼 테스트 — 빌드 후 수동 검증 필요
