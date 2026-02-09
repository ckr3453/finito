# Task 08: UI - 카테고리/태그 관리 + 필터/검색

## 의존성
- **Task 05** (Providers)
- **Task 06** (Router)
- **Task 07** (홈 화면) — 동시 진행 가능하지만, shared_widgets 충돌 주의

## 목표
카테고리 관리 화면, 태그 관리, 검색 화면, 필터링 기능 구현.

## 생성할 파일

### 1. `lib/presentation/screens/categories/categories_screen.dart`
- 카테고리 목록 (아이콘 + 컬러 + 이름 + 태스크 개수)
- FAB: 카테고리 추가 다이얼로그
- 탭: 해당 카테고리로 필터링된 태스크 목록
- 롱프레스: 편집/삭제 옵션

### 2. `lib/presentation/screens/categories/category_editor_dialog.dart`
- 이름 입력
- 컬러 피커 (미리 정의된 8색 그리드)
- 아이콘 선택 (folder, work, home, shopping, health, study 등)
- 저장/취소 버튼

### 3. `lib/presentation/screens/search/search_screen.dart`
- 상단 검색바 (TextField with autofocus)
- 실시간 검색 (debounce 300ms)
- ref.watch(taskFilterProvider)의 searchQuery 업데이트
- 결과 목록: TaskListTile 재사용
- 빈 결과: "검색 결과가 없습니다"

### 4. `lib/presentation/shared_widgets/filter_bar.dart`
- 홈 화면 상단에 배치
- 상태 필터: 전체 / 진행중 / 완료
- 우선순위 필터: 전체 / 높음 / 보통 / 낮음
- 카테고리 필터: 드롭다운
- 정렬: 생성일 / 마감일 / 우선순위 / 이름
- 활성 필터 개수 배지

### 5. `lib/presentation/shared_widgets/color_picker_grid.dart`
- 미리 정의된 색상 그리드 (8~12색)
- 선택된 색상에 체크 아이콘
- 카테고리/태그 편집에서 재사용

### 6. `lib/presentation/screens/settings/settings_screen.dart`
- 테마 선택 (시스템/라이트/다크)
- 향후 확장: 알림 설정, 동기화 설정, 계정 관리
- ThemeMode_ provider 사용

## 완료 조건
- 카테고리 CRUD 동작
- 검색으로 태스크 찾기 가능
- 필터링 조합 동작 (상태+우선순위+카테고리)
- 설정에서 테마 변경 즉시 반영
- 컴파일 에러 없음
