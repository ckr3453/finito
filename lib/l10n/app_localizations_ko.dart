// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TODO';

  @override
  String get filterAll => '전체';

  @override
  String get filterInProgress => '진행중';

  @override
  String get filterCompleted => '완료';

  @override
  String get emptyTaskMessage => '할 일을 추가해보세요!';

  @override
  String get emptyTaskAction => '새 할 일 추가';

  @override
  String errorOccurred(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get deleteTask => '할 일 삭제';

  @override
  String deleteTaskConfirm(String title) {
    return '\"$title\" 을(를) 삭제하시겠습니까?';
  }

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get searchHint => '할 일 검색...';

  @override
  String get searchPrompt => '검색어를 입력하세요';

  @override
  String get searchNoResults => '검색 결과가 없습니다';

  @override
  String get categories => '카테고리';

  @override
  String get emptyCategoryMessage => '카테고리가 없습니다';

  @override
  String get emptyCategoryHint => '+ 버튼을 눌러 카테고리를 추가하세요';

  @override
  String get edit => '편집';

  @override
  String get deleteCategoryTitle => '카테고리 삭제';

  @override
  String deleteCategoryConfirm(String name) {
    return '\"$name\" 카테고리를 삭제하시겠습니까?';
  }

  @override
  String get editCategory => '카테고리 편집';

  @override
  String get addCategory => '카테고리 추가';

  @override
  String get categoryName => '이름';

  @override
  String get categoryNameHint => '카테고리 이름을 입력하세요';

  @override
  String get color => '색상';

  @override
  String get icon => '아이콘';

  @override
  String get save => '저장';

  @override
  String get taskDetail => '할 일 상세';

  @override
  String get editTooltip => '수정';

  @override
  String get deleteTooltip => '삭제';

  @override
  String get taskNotFound => '할 일을 찾을 수 없습니다.';

  @override
  String get priority => '우선순위';

  @override
  String get priorityHigh => '높음';

  @override
  String get priorityMedium => '보통';

  @override
  String get priorityLow => '낮음';

  @override
  String get description => '설명';

  @override
  String get category => '카테고리';

  @override
  String get tags => '태그';

  @override
  String get dueDate => '마감일';

  @override
  String get reminder => '리마인더';

  @override
  String get createdAt => '생성일';

  @override
  String get updatedAt => '수정일';

  @override
  String get markAsIncomplete => '미완료로 변경';

  @override
  String get markAsComplete => '완료로 변경';

  @override
  String get deleteTaskDialogContent => '이 할 일을 삭제하시겠습니까?';

  @override
  String get statusPending => '진행중';

  @override
  String get statusCompleted => '완료';

  @override
  String get statusArchived => '보관';

  @override
  String get editTask => '할 일 수정';

  @override
  String get newTask => '새 할 일';

  @override
  String get title => '제목';

  @override
  String get titleHint => '할 일을 입력하세요';

  @override
  String get titleRequired => '제목을 입력해주세요';

  @override
  String get descriptionHint => '설명을 입력하세요 (선택)';

  @override
  String get none => '없음';

  @override
  String categoryLoadFailed(String error) {
    return '카테고리 로딩 실패: $error';
  }

  @override
  String dueDateLabel(String date) {
    return '마감일: $date';
  }

  @override
  String get setDueDate => '마감일 설정';

  @override
  String reminderLabel(String dateTime) {
    return '리마인더: $dateTime';
  }

  @override
  String get setReminder => '리마인더 설정';

  @override
  String get noTags => '태그가 없습니다';

  @override
  String tagLoadFailed(String error) {
    return '태그 로딩 실패: $error';
  }

  @override
  String saveFailed(String error) {
    return '저장 실패: $error';
  }

  @override
  String get login => '로그인';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get emailRequired => '이메일을 입력해주세요.';

  @override
  String get passwordRequired => '비밀번호를 입력해주세요.';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get or => '또는';

  @override
  String get signInWithGoogle => 'Google로 로그인';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get signUp => '회원가입';

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get resetEmailHint => '가입한 이메일을 입력하세요';

  @override
  String get send => '전송';

  @override
  String get resetEmailSent => '비밀번호 재설정 이메일을 전송했습니다.';

  @override
  String get loginFailed => '로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get googleLoginFailed => 'Google 로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get firebaseUserNotFound => '등록되지 않은 이메일입니다.';

  @override
  String get firebaseWrongPassword => '비밀번호가 올바르지 않습니다.';

  @override
  String get firebaseInvalidEmail => '유효하지 않은 이메일 형식입니다.';

  @override
  String get firebaseUserDisabled => '비활성화된 계정입니다.';

  @override
  String get firebaseTooManyRequests => '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get firebaseInvalidCredential => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get firebaseNetworkError => '네트워크 연결을 확인해주세요.';

  @override
  String get createAccount => '새 계정 만들기';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get confirmPasswordRequired => '비밀번호를 다시 입력해주세요.';

  @override
  String get passwordTooShort => '비밀번호는 6자 이상이어야 합니다.';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get hasAccount => '이미 계정이 있으신가요?';

  @override
  String get signUpFailed => '회원가입에 실패했습니다. 다시 시도해주세요.';

  @override
  String get googleSignUpFailed => 'Google 로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get firebaseEmailInUse => '이미 사용 중인 이메일입니다.';

  @override
  String get firebaseWeakPassword => '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';

  @override
  String get firebaseOperationNotAllowed => '이메일/비밀번호 가입이 비활성화되어 있습니다.';

  @override
  String get settings => '설정';

  @override
  String get appearance => '외관';

  @override
  String get theme => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifications => '알림';

  @override
  String get notificationPermission => '알림 권한';

  @override
  String get notificationPermissionDesc => '리마인더 알림을 받으려면 권한이 필요합니다';

  @override
  String get requestPermission => '권한 요청';

  @override
  String get permissionGranted => '알림 권한이 허용되었습니다';

  @override
  String get permissionDenied => '알림 권한이 거부되었습니다';

  @override
  String get sync => '동기화';

  @override
  String get syncDisabledMessage => '로그인하면 동기화를 사용할 수 있습니다';

  @override
  String get syncStatus => '동기화 상태';

  @override
  String get syncNow => '지금 동기화';

  @override
  String get syncPending => '동기화 대기';

  @override
  String syncPendingCount(int count) {
    return '$count개 항목이 동기화되지 않았습니다';
  }

  @override
  String get syncIdle => '동기화 완료';

  @override
  String get syncing => '동기화 중...';

  @override
  String get syncError => '동기화 오류';

  @override
  String get syncOffline => '오프라인';

  @override
  String get account => '계정';

  @override
  String get loginPrompt => '로그인하여 데이터를 동기화하세요';

  @override
  String get user => '사용자';

  @override
  String get loggedIn => '로그인됨';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '로그아웃 하시겠습니까?';

  @override
  String get emailNotVerified => '이메일 미인증';

  @override
  String get emailNotVerifiedDesc => '이메일 주소를 인증해주세요.';

  @override
  String get sendVerificationEmail => '인증 이메일 발송';

  @override
  String get verificationEmailSent => '인증 이메일을 발송했습니다. 받은편지함을 확인해주세요.';

  @override
  String get checkVerification => '인증 상태 확인';

  @override
  String get emailVerified => '이메일 인증 완료';

  @override
  String get emailNotYetVerified => '아직 이메일이 인증되지 않았습니다. 받은편지함을 확인해주세요.';

  @override
  String get relativeToday => '오늘';

  @override
  String get relativeYesterday => '어제';

  @override
  String relativeDaysAgo(int days) {
    return '$days일 전';
  }
}
