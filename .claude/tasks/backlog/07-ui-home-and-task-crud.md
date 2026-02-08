# Task 07: UI - 홈 화면 + Task CRUD

## 의존성
- **Task 05** (Providers)
- **Task 06** (Router)

## 목표
홈 화면에 태스크 목록 표시, FAB으로 새 태스크 생성, 태스크 상세/편집 화면, 완료 토글, 삭제, 우선순위 표시.

## 생성할 파일

### 1. `lib/presentation/screens/home/home_screen.dart`
- `ConsumerWidget`
- `ref.watch(taskListProvider)`로 태스크 목록 구독
- 상단: 필터 칩 (전체/진행중/완료)
- 중앙: `ListView.builder` 또는 빈 상태 표시
- FAB: 태스크 추가 (`context.pushNamed('taskEditor')`)

### 2. `lib/presentation/shared_widgets/task_list_tile.dart`
- 체크박스 (완료 토글)
- 제목 + 마감일 + 우선순위 색상 인디케이터
- 카테고리 칩 (있으면)
- 탭: 상세 화면으로 이동
- 롱프레스 또는 스와이프: 삭제
- 우선순위별 좌측 컬러 바: high=red, medium=orange, low=grey

### 3. `lib/presentation/screens/task_editor/task_editor_screen.dart`
- taskId가 null이면 신규 생성, 있으면 수정
- 필드: 제목(필수), 설명, 우선순위 드롭다운, 카테고리 드롭다운, 태그 멀티셀렉트, 마감일 DatePicker
- 저장 버튼: repository를 통해 저장 후 pop
- uuid 패키지로 새 ID 생성

### 4. `lib/presentation/screens/task_detail/task_detail_screen.dart`
- taskId로 상세 정보 표시
- 상단: 제목, 상태 배지
- 중앙: 설명, 카테고리, 태그 목록, 마감일, 우선순위
- AppBar 액션: 편집 아이콘 → task_editor로 이동, 삭제 아이콘
- 완료/미완료 토글 버튼

### 5. `lib/presentation/shared_widgets/empty_state.dart`
- 아이콘 + 메시지 + 선택적 액션 버튼
- 태스크 없을 때 "할 일을 추가해보세요!" 표시

### 6. `lib/presentation/shared_widgets/priority_indicator.dart`
- 우선순위별 컬러 도트/바 위젯

## UI 가이드
- Material 3 디자인 사용
- `Dismissible`로 스와이프 삭제 (확인 다이얼로그 포함)
- 낙관적 업데이트: 체크박스 탭 시 즉시 UI 반영
- 마감일 지난 태스크는 빨간색 표시

## 완료 조건
- 태스크 목록이 화면에 표시됨
- 태스크 생성/수정/삭제 가능
- 완료 토글 동작
- 빈 상태 처리
- 컴파일 에러 없음
