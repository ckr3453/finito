# 앱 아이콘 + 스플래시 스크린

- size: S

## 목표
- 앱 아이콘 디자인 및 적용 (iOS, Android, macOS, Windows)
- 스플래시 스크린 구현

## 완료 기준
- [x] 플랫폼별 앱 아이콘 적용
- [x] 스플래시 스크린 표시 후 홈 화면 전환

---

**completed: 2026-02-11**

## 완료 내용
- Python + Pillow로 1024x1024 앱 아이콘 생성 (초록색 배경 + 흰색 체크마크)
- flutter_launcher_icons + flutter_native_splash 패키지 추가
- 모든 플랫폼(Android, iOS, macOS, Windows)에 아이콘 및 스플래시 자동 생성
- main.dart에 FlutterNativeSplash.preserve/remove 로직 추가
- 모든 플랫폼 앱 이름을 "Finito"로 통일
- Dart 코드 분석 통과 확인
