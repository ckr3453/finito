# 스토어 배포

- size: M
- status: 보류

## 목표
- Google Play Store 배포 준비
- Apple App Store 배포 준비

## 완료 기준
- [ ] 서명 키 설정 (Android keystore, iOS provisioning)
- [ ] 스토어 메타데이터 작성 (스크린샷, 설명)
- [ ] 릴리스 빌드 생성 및 제출

## 보류 사유 (2026-02-11)
- 개인 사용 목적이라 스토어 배포 비용이 비효율적
  - Google Play: $25 (1회)
  - Apple App Store: $99/년
- 당분간 로컬 빌드 직접 설치 방식으로 운용
  - macOS/Windows: 직접 빌드
  - Android: APK 사이드로딩
  - iOS: Xcode 직접 설치 (무료, 7일마다 재설치)
- 웹 PWA 배포도 검토했으나 Drift(SQLite) 웹 호환 작업량이 커서 보류
- 필요 시 재개
