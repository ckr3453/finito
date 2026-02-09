# Task 09: 코드 생성 + 빌드 검증 + 통합

## 의존성
- **모든 태스크** (01~08) 완료 필요

## 목표
모든 코드가 작성된 후, build_runner로 코드 생성하고, 전체 빌드/분석이 성공하는지 확인. 누락되거나 불일치하는 부분 수정.

## 실행 단계

### 1. 코드 생성
```bash
cd C:/Users/david/todo_app
C:/flutter/bin/dart run build_runner build --delete-conflicting-outputs
```

### 2. 분석
```bash
C:/flutter/bin/flutter analyze
```

### 3. 빌드 테스트 (Windows)
```bash
C:/flutter/bin/flutter build windows --debug
```

### 4. 수정 사항 체크리스트
- [ ] 모든 import 경로가 올바른지
- [ ] Freezed `.freezed.dart` / `.g.dart` 생성 확인
- [ ] Drift `.g.dart` 생성 확인
- [ ] Riverpod `.g.dart` 생성 확인
- [ ] 타입 불일치 수정
- [ ] 누락된 barrel export 추가
- [ ] main.dart에서 앱 실행 가능

### 5. Git Commit
모든 수정 후 커밋:
```
Phase 1 complete: Local-only TODO app with CRUD, categories, tags, filtering
```

## 완료 조건
- `build_runner` 에러 없음
- `flutter analyze` 에러 없음
- Windows 디버그 빌드 성공
- 앱 실행 시 홈 화면 표시

## 주의사항
- 여러 세션에서 병렬로 작성된 코드의 일관성 검증이 핵심
- Drift 테이블 클래스명 ↔ DAO 참조 일치 확인
- Provider 이름 일치 확인 (riverpod_generator가 생성하는 이름)
- Screen placeholder 남아있으면 실제 구현으로 교체
