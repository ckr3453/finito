# Phase 5: 알림 — 로컬 리마인더 + FCM (2026-02-10)

## Phase 5-A: 데이터 모델 + 마이그레이션
- [x] 5-1. (S) TaskEntity에 `reminderTime` 필드 추가 + Freezed 재빌드
- [x] 5-2. (S) Drift 스키마 v3 마이그레이션 — `reminderTime` 컬럼
- [x] 5-3. (S) Repository + DTO 레이어에 `reminderTime` 반영

## Phase 5-B: 로컬 알림 서비스 (Core)
- [x] 5-4. (S) pubspec.yaml에 패키지 추가
- [x] 5-5. (M) LocalNotificationClient 추상화 + 구현
- [x] 5-6. (M) NotificationService 인터페이스 + 구현 (TDD)
- [x] 5-7. (S) NotificationService Provider + 초기화

## Phase 5-C: FCM 토큰 관리
- [x] 5-8. (M) FcmClient 추상화 + FcmService (TDD)
- [x] 5-9. (S) FCM Provider + auth-gated 초기화

## Phase 5-D: UI
- [x] 5-10. (M) TaskEditor에 리마인더 DateTimePicker 추가
- [x] 5-11. (S) TaskDetail에 리마인더 시간 표시
- [x] 5-12. (S) 알림 탭 → 태스크 상세 화면 네비게이션
- [x] 5-13. (S) Settings에 알림 섹션 추가

## Phase 5-E: 플랫폼 설정 + 통합
- [x] 5-14. (S) Android 알림 권한 설정 (AndroidManifest)
- [x] 5-15. (S) iOS 알림 설정 (Info.plist background modes)
- [x] 5-16. (S) 동기화 후 리마인더 자동 재스케줄
- [x] 5-17. (M) 통합 테스트
