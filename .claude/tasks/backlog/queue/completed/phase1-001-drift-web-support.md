# Drift 웹 지원 셋업

- phase: 1
- size: L

## 목표
- drift_flutter 패키지로 웹에서도 SQLite(IndexedDB fallback) 동작하도록 구성
- conditional import 패턴으로 widget/notification 계층 웹 호환
- Firebase 웹 설정 + Google Sign-In OAuth Client ID 적용
- CI 커버리지 필터를 비즈니스 로직 중심(60%)으로 개선

## 완료 기준
- [x] `fvm flutter build web` 성공
- [x] 웹에서 Drift DB(IndexedDB) 정상 동작
- [x] Google Sign-In 웹에서 동작
- [x] CI 커버리지 60% 이상 통과
- [x] PR #25 머지 완료

## 완료일: 2026-02-25
