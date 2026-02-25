# Roadmap

## 이전 로드맵
- [Roadmap v1](../archive/roadmap-v1/) — Phase 1~5 + Infra (2026-02-08 ~ 2026-02-10)

## Phase 1: 웹+데스크탑 전환 기반 ✅
- Drift 웹 지원 (drift_flutter, IndexedDB fallback)
- 웹 플랫폼 생성 + 에셋 (sqlite3.wasm, drift_worker.js)
- conditional import (widget, notification)
- Firebase 웹 설정 + Google Sign-In 웹 OAuth
- CI 커버리지 필터 개선 (비즈니스 로직 중심 60%)
- completed: 2026-02-25

## Phase 2: 웹 UI 개선 ✅
- 브라우저 탭 제목/파비콘 커스텀
- 앱 타이틀 변경 (TODO → 할 일 목록/Tasks)
- 팝업 다이얼로그 (할일 등록/상세 — 와이드 스크린)
- 필터 칩 Wrap 레이아웃 + 정렬 칩 인라인
- 한국어 폰트 번들링 (Noto Sans KR)
- 드래그 핸들 좌측 이동
- 할일 목록 타일 정보 확장 (마감일+리마인더+카테고리)
- 정렬 기능 (마감일/우선순위/생성일)
- 완료 토글 피드백 (SnackBar)
- 마감일 시간 선택 + 리마인더 프리셋
- 테마 설정 연결 수정
- 웹 알림 섹션 숨김
- 카테고리 빈 상태 UI 일관성
- 커스텀 앱 아이콘 (web/macOS/Windows)
- 필터별 빈 상태 메시지
- macOS Widget Extension 타겟 설정
- completed: 2026-02-25

## Phase 3: 알림 시스템 고도화 ⬜
- Cloud Functions 기반 리마인더 스케줄러
- 이메일 알림 발송 (마감일 임박 시)
- 알림 채널 설정 (이메일 on/off)

## Phase 4: 태그 관리 ⬜
- 태그 CRUD UI 화면 (생성/편집/삭제)
- 태그와 카테고리 역할 분리 명확화

## Phase 5: 설명 마크다운 에디터 ⬜
- 할일 설명 입력 시 툴바 제공 (Bold, Italic, List 등)
- 툴바 버튼 → 마크다운 문법 자동 삽입
- 할일 상세 화면에서 마크다운 렌더링 (flutter_markdown)

## 기타 (우선순위 낮음) ⬜
- 익명 로그인
- 이메일 인증 강제
- ✅ 계정 삭제 (completed: 2026-02-10)
- ✅ 드래그앤드롭 정렬 개선 (completed: 2026-02-25)
- ✅ 다국어 지원 (i18n) (completed: 2026-02-11)
- ✅ 앱 아이콘 + 스플래시 스크린 (completed: 2026-02-11)
- ⏸️ 스토어 배포 (Google Play, App Store) — 보류: 개인 사용 목적, 로컬 빌드로 운용
