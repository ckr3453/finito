# Cloud Functions 기반 리마인더 스케줄러

- phase: 3
- size: L
- blocked_by: phase2-001-web-ui-improvements

## 목표
- Firebase Cloud Functions로 서버 사이드 리마인더 스케줄링
- 마감일 임박 시 이메일 알림 발송

## 완료 기준
- [ ] Cloud Functions 프로젝트 초기화 (functions/ 디렉토리)
- [ ] cron 스케줄러 함수: Firestore에서 리마인더 시간 임박 태스크 조회
- [ ] 이메일 발송 연동 (SendGrid 또는 Firebase Extensions)
- [ ] 사용자별 이메일 알림 설정 (on/off) Firestore 필드 추가
- [ ] 설정 화면에 이메일 알림 토글 UI 추가
- [ ] 테스트: 리마인더 시간 도래 시 이메일 수신 확인
