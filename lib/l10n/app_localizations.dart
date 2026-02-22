import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'TODO'**
  String get appTitle;

  /// No description provided for @filterAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get filterAll;

  /// No description provided for @filterInProgress.
  ///
  /// In ko, this message translates to:
  /// **'진행중'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get filterCompleted;

  /// No description provided for @emptyTaskMessage.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 추가해보세요!'**
  String get emptyTaskMessage;

  /// No description provided for @emptyTaskAction.
  ///
  /// In ko, this message translates to:
  /// **'새 할 일 추가'**
  String get emptyTaskAction;

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다: {error}'**
  String errorOccurred(String error);

  /// No description provided for @deleteTask.
  ///
  /// In ko, this message translates to:
  /// **'할 일 삭제'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{title}\" 을(를) 삭제하시겠습니까?'**
  String deleteTaskConfirm(String title);

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @searchHint.
  ///
  /// In ko, this message translates to:
  /// **'할 일 검색...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In ko, this message translates to:
  /// **'검색어를 입력하세요'**
  String get searchPrompt;

  /// No description provided for @searchNoResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get searchNoResults;

  /// No description provided for @categories.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get categories;

  /// No description provided for @emptyCategoryMessage.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 없습니다'**
  String get emptyCategoryMessage;

  /// No description provided for @emptyCategoryHint.
  ///
  /// In ko, this message translates to:
  /// **'+ 버튼을 눌러 카테고리를 추가하세요'**
  String get emptyCategoryHint;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get edit;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 삭제'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 카테고리를 삭제하시겠습니까?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @editCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 편집'**
  String get editCategory;

  /// No description provided for @addCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 추가'**
  String get addCategory;

  /// No description provided for @categoryName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 이름을 입력하세요'**
  String get categoryNameHint;

  /// No description provided for @color.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘'**
  String get icon;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @taskDetail.
  ///
  /// In ko, this message translates to:
  /// **'할 일 상세'**
  String get taskDetail;

  /// No description provided for @editTooltip.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get deleteTooltip;

  /// No description provided for @taskNotFound.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 찾을 수 없습니다.'**
  String get taskNotFound;

  /// No description provided for @priority.
  ///
  /// In ko, this message translates to:
  /// **'우선순위'**
  String get priority;

  /// No description provided for @priorityHigh.
  ///
  /// In ko, this message translates to:
  /// **'높음'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In ko, this message translates to:
  /// **'낮음'**
  String get priorityLow;

  /// No description provided for @description.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get description;

  /// No description provided for @category.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get category;

  /// No description provided for @tags.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get tags;

  /// No description provided for @dueDate.
  ///
  /// In ko, this message translates to:
  /// **'마감일'**
  String get dueDate;

  /// No description provided for @reminder.
  ///
  /// In ko, this message translates to:
  /// **'리마인더'**
  String get reminder;

  /// No description provided for @createdAt.
  ///
  /// In ko, this message translates to:
  /// **'생성일'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In ko, this message translates to:
  /// **'수정일'**
  String get updatedAt;

  /// No description provided for @markAsIncomplete.
  ///
  /// In ko, this message translates to:
  /// **'미완료로 변경'**
  String get markAsIncomplete;

  /// No description provided for @markAsComplete.
  ///
  /// In ko, this message translates to:
  /// **'완료로 변경'**
  String get markAsComplete;

  /// No description provided for @deleteTaskDialogContent.
  ///
  /// In ko, this message translates to:
  /// **'이 할 일을 삭제하시겠습니까?'**
  String get deleteTaskDialogContent;

  /// No description provided for @statusPending.
  ///
  /// In ko, this message translates to:
  /// **'진행중'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get statusCompleted;

  /// No description provided for @statusArchived.
  ///
  /// In ko, this message translates to:
  /// **'보관'**
  String get statusArchived;

  /// No description provided for @editTask.
  ///
  /// In ko, this message translates to:
  /// **'할 일 수정'**
  String get editTask;

  /// No description provided for @newTask.
  ///
  /// In ko, this message translates to:
  /// **'새 할 일'**
  String get newTask;

  /// No description provided for @title.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 입력하세요'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력해주세요'**
  String get titleRequired;

  /// No description provided for @descriptionHint.
  ///
  /// In ko, this message translates to:
  /// **'설명을 입력하세요 (선택)'**
  String get descriptionHint;

  /// No description provided for @none.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get none;

  /// No description provided for @categoryLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 로딩 실패: {error}'**
  String categoryLoadFailed(String error);

  /// No description provided for @dueDateLabel.
  ///
  /// In ko, this message translates to:
  /// **'마감일: {date}'**
  String dueDateLabel(String date);

  /// No description provided for @setDueDate.
  ///
  /// In ko, this message translates to:
  /// **'마감일 설정'**
  String get setDueDate;

  /// No description provided for @reminderLabel.
  ///
  /// In ko, this message translates to:
  /// **'리마인더: {dateTime}'**
  String reminderLabel(String dateTime);

  /// No description provided for @setReminder.
  ///
  /// In ko, this message translates to:
  /// **'리마인더 설정'**
  String get setReminder;

  /// No description provided for @noTags.
  ///
  /// In ko, this message translates to:
  /// **'태그가 없습니다'**
  String get noTags;

  /// No description provided for @tagLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'태그 로딩 실패: {error}'**
  String tagLoadFailed(String error);

  /// No description provided for @saveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String saveFailed(String error);

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력해주세요.'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력해주세요.'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 잊으셨나요?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 로그인'**
  String get signInWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정이 없으신가요?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signUp;

  /// No description provided for @resetPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 재설정'**
  String get resetPassword;

  /// No description provided for @resetEmailHint.
  ///
  /// In ko, this message translates to:
  /// **'가입한 이메일을 입력하세요'**
  String get resetEmailHint;

  /// No description provided for @send.
  ///
  /// In ko, this message translates to:
  /// **'전송'**
  String get send;

  /// No description provided for @resetEmailSent.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 재설정 이메일을 전송했습니다.'**
  String get resetEmailSent;

  /// No description provided for @loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다. 다시 시도해주세요.'**
  String get loginFailed;

  /// No description provided for @googleLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google 로그인에 실패했습니다. 다시 시도해주세요.'**
  String get googleLoginFailed;

  /// No description provided for @firebaseUserNotFound.
  ///
  /// In ko, this message translates to:
  /// **'등록되지 않은 이메일입니다.'**
  String get firebaseUserNotFound;

  /// No description provided for @firebaseWrongPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 올바르지 않습니다.'**
  String get firebaseWrongPassword;

  /// No description provided for @firebaseInvalidEmail.
  ///
  /// In ko, this message translates to:
  /// **'유효하지 않은 이메일 형식입니다.'**
  String get firebaseInvalidEmail;

  /// No description provided for @firebaseUserDisabled.
  ///
  /// In ko, this message translates to:
  /// **'비활성화된 계정입니다.'**
  String get firebaseUserDisabled;

  /// No description provided for @firebaseTooManyRequests.
  ///
  /// In ko, this message translates to:
  /// **'너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.'**
  String get firebaseTooManyRequests;

  /// No description provided for @firebaseInvalidCredential.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않습니다.'**
  String get firebaseInvalidCredential;

  /// No description provided for @firebaseNetworkError.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요.'**
  String get firebaseNetworkError;

  /// No description provided for @createAccount.
  ///
  /// In ko, this message translates to:
  /// **'새 계정 만들기'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 다시 입력해주세요.'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다.'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 일치하지 않습니다.'**
  String get passwordMismatch;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get continueWithGoogle;

  /// No description provided for @hasAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요?'**
  String get hasAccount;

  /// No description provided for @signUpFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다. 다시 시도해주세요.'**
  String get signUpFailed;

  /// No description provided for @googleSignUpFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google 로그인에 실패했습니다. 다시 시도해주세요.'**
  String get googleSignUpFailed;

  /// No description provided for @firebaseEmailInUse.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 이메일입니다.'**
  String get firebaseEmailInUse;

  /// No description provided for @firebaseWeakPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 너무 약합니다. 6자 이상 입력해주세요.'**
  String get firebaseWeakPassword;

  /// No description provided for @firebaseOperationNotAllowed.
  ///
  /// In ko, this message translates to:
  /// **'이메일/비밀번호 가입이 비활성화되어 있습니다.'**
  String get firebaseOperationNotAllowed;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ko, this message translates to:
  /// **'외관'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get languageSystem;

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @notificationPermission.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'리마인더 알림을 받으려면 권한이 필요합니다'**
  String get notificationPermissionDesc;

  /// No description provided for @requestPermission.
  ///
  /// In ko, this message translates to:
  /// **'권한 요청'**
  String get requestPermission;

  /// No description provided for @permissionGranted.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 허용되었습니다'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 거부되었습니다'**
  String get permissionDenied;

  /// No description provided for @sync.
  ///
  /// In ko, this message translates to:
  /// **'동기화'**
  String get sync;

  /// No description provided for @syncDisabledMessage.
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 동기화를 사용할 수 있습니다'**
  String get syncDisabledMessage;

  /// No description provided for @syncStatus.
  ///
  /// In ko, this message translates to:
  /// **'동기화 상태'**
  String get syncStatus;

  /// No description provided for @syncNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 동기화'**
  String get syncNow;

  /// No description provided for @syncPending.
  ///
  /// In ko, this message translates to:
  /// **'동기화 대기'**
  String get syncPending;

  /// No description provided for @syncPendingCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 항목이 동기화되지 않았습니다'**
  String syncPendingCount(int count);

  /// No description provided for @syncIdle.
  ///
  /// In ko, this message translates to:
  /// **'동기화 완료'**
  String get syncIdle;

  /// No description provided for @syncing.
  ///
  /// In ko, this message translates to:
  /// **'동기화 중...'**
  String get syncing;

  /// No description provided for @syncError.
  ///
  /// In ko, this message translates to:
  /// **'동기화 오류'**
  String get syncError;

  /// No description provided for @syncOffline.
  ///
  /// In ko, this message translates to:
  /// **'오프라인'**
  String get syncOffline;

  /// No description provided for @account.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// No description provided for @loginPrompt.
  ///
  /// In ko, this message translates to:
  /// **'로그인하여 데이터를 동기화하세요'**
  String get loginPrompt;

  /// No description provided for @user.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get user;

  /// No description provided for @loggedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인됨'**
  String get loggedIn;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @emailNotVerified.
  ///
  /// In ko, this message translates to:
  /// **'이메일 미인증'**
  String get emailNotVerified;

  /// No description provided for @emailNotVerifiedDesc.
  ///
  /// In ko, this message translates to:
  /// **'이메일 주소를 인증해주세요.'**
  String get emailNotVerifiedDesc;

  /// No description provided for @sendVerificationEmail.
  ///
  /// In ko, this message translates to:
  /// **'인증 이메일 발송'**
  String get sendVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In ko, this message translates to:
  /// **'인증 이메일을 발송했습니다. 받은편지함을 확인해주세요.'**
  String get verificationEmailSent;

  /// No description provided for @checkVerification.
  ///
  /// In ko, this message translates to:
  /// **'인증 상태 확인'**
  String get checkVerification;

  /// No description provided for @emailVerified.
  ///
  /// In ko, this message translates to:
  /// **'이메일 인증 완료'**
  String get emailVerified;

  /// No description provided for @emailNotYetVerified.
  ///
  /// In ko, this message translates to:
  /// **'아직 이메일이 인증되지 않았습니다. 받은편지함을 확인해주세요.'**
  String get emailNotYetVerified;

  /// No description provided for @relativeToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In ko, this message translates to:
  /// **'어제'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 전'**
  String relativeDaysAgo(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
