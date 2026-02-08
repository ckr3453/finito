# Task Backlog

## Queue (proceed in order)

### Phase 2B: Firestore Task Sync
1. task-drift-schema-v2.md (S) — deletedAt 컬럼 + v1→v2 마이그레이션
2. task-entity-deleted-at.md (S) — TaskEntity에 deletedAt 추가 + build_runner (blocked by: 1)
3. task-dao-soft-delete.md (M) — TaskDao soft delete + 필터 + upsert (blocked by: 2)
4. task-local-repo-update.md (S) — LocalTaskRepository deletedAt 매핑 (blocked by: 3)
5. task-firestore-dto.md (S) — TaskFirestoreDto 작성 (blocked by: 2)
6. task-remote-datasource.md (M) — FirestoreTaskDataSource 인터페이스 + 구현 (blocked by: 5)
7. task-connectivity-service.md (S) — ConnectivityService 작성
8. task-sync-service.md (L) — TaskSyncService 핵심 로직 (blocked by: 4, 6, 7)
9. task-synced-repository.md (M) — SyncedTaskRepository 작성 (blocked by: 8)
10. task-sync-providers.md (M) — Provider 변경 (blocked by: 9)
11. task-sync-settings-ui.md (S) — 설정 화면 동기화 섹션 (blocked by: 10)
12. task-sync-tests.md (M) — 단위 테스트 (blocked by: 10)

### Phase 3+
13. task-google-auth.md (M) — Phase 3: Google 소셜 로그인 (blocked by: 12)
14. task-native-widget.md (L) — Phase 4: Native Widget Bridge
15. task-notifications.md (L) — Phase 5: 알림 (FCM + 로컬)

## Independent Tasks (can run anytime)
- task-app-icon-splash.md (S) - 앱 아이콘 + 스플래시 스크린
- task-i18n.md (M) - 다국어 지원
- task-store-deploy.md (M) - 스토어 배포

## Completed
- ~~01-domain-models.md~~ → Phase 1
- ~~02-drift-database.md~~ → Phase 1
- ~~03-repository-layer.md~~ → Phase 1
- ~~04-core-and-theme.md~~ → Phase 1
- ~~05-riverpod-providers.md~~ → Phase 1
- ~~06-router-and-main.md~~ → Phase 1
- ~~07-ui-home-and-task-crud.md~~ → Phase 1
- ~~08-ui-categories-tags-search.md~~ → Phase 1
- ~~09-build-and-verify.md~~ → Phase 1
- ~~firebase-auth.md~~ → Phase 2A (2026-02-09)
- ~~ci-pipeline.md~~ → 인프라
- ~~lefthook-setup.md~~ → 인프라
- ~~unit-widget-tests.md~~ → 인프라
- ~~git-conventions.md~~ → 인프라
