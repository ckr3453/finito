# Task Backlog

## Archived Phases
- [Phase 1](../archive/phase-1.md) — 로컬 TODO 앱 (9 tasks, 2026-02-08)
- [Phase 2A](../archive/phase-2a.md) — Firebase Auth (1 task, 2026-02-09)
- [Infra](../archive/infra.md) — CI, lefthook, tests, git conventions (4 tasks)

## Queue (Phase 2B: Firestore 동기화)
11. (S) 설정 화면 동기화 섹션 UI — blocked by: 10
12. (M) 동기화 통합 테스트 — blocked by: 10

### Phase 3+
13. (M) Google 소셜 로그인 — blocked by: 12
14. (L) Native Widget Bridge (iOS/Android/Windows)
15. (L) 알림 (FCM + 로컬)

## Independent Tasks
- (S) 앱 아이콘 + 스플래시 스크린
- (M) 다국어 지원
- (M) 스토어 배포

## Completed (Phase 2B)
- ~~Drift schema v2 (deletedAt)~~ (2026-02-09)
- ~~TaskEntity deletedAt 필드~~ (2026-02-09)
- ~~TaskDao soft delete~~ (2026-02-09)
- ~~LocalTaskRepository 업데이트~~ (2026-02-09)
- ~~ConnectivityService~~ (2026-02-09)
- ~~TaskFirestoreDto~~ (2026-02-10)
- ~~FirestoreTaskDataSource~~ (2026-02-10)
- ~~TaskSyncService~~ (2026-02-10)
- ~~SyncedTaskRepository~~ (2026-02-10)
- ~~Provider 변경 (조건부 Synced/Local)~~ (2026-02-10)
