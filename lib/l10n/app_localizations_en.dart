// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tasks';

  @override
  String get filterAll => 'All';

  @override
  String get filterInProgress => 'In Progress';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get emptyTaskMessage => 'Add a task to get started!';

  @override
  String get emptyTaskAction => 'Add New Task';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get deleteTask => 'Delete Task';

  @override
  String deleteTaskConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get searchHint => 'Search tasks...';

  @override
  String get searchPrompt => 'Enter a search term';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get categories => 'Categories';

  @override
  String get emptyCategoryMessage => 'No categories';

  @override
  String get emptyCategoryHint => 'Tap + to add a category';

  @override
  String get edit => 'Edit';

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete category \"$name\"?';
  }

  @override
  String get editCategory => 'Edit Category';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryNameHint => 'Enter category name';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get save => 'Save';

  @override
  String get taskDetail => 'Task Detail';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get taskNotFound => 'Task not found.';

  @override
  String get priority => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get tags => 'Tags';

  @override
  String get dueDate => 'Due Date';

  @override
  String get reminder => 'Reminder';

  @override
  String get createdAt => 'Created';

  @override
  String get updatedAt => 'Updated';

  @override
  String get markAsIncomplete => 'Mark as Incomplete';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get deleteTaskDialogContent => 'Delete this task?';

  @override
  String get statusPending => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusArchived => 'Archived';

  @override
  String get editTask => 'Edit Task';

  @override
  String get newTask => 'New Task';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'Enter a task';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get descriptionHint => 'Enter description (optional)';

  @override
  String get none => 'None';

  @override
  String categoryLoadFailed(String error) {
    return 'Failed to load categories: $error';
  }

  @override
  String dueDateLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get setDueDate => 'Set Due Date';

  @override
  String reminderLabel(String dateTime) {
    return 'Reminder: $dateTime';
  }

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get noTags => 'No tags';

  @override
  String tagLoadFailed(String error) {
    return 'Failed to load tags: $error';
  }

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Please enter your email.';

  @override
  String get passwordRequired => 'Please enter your password.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get or => 'or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetEmailHint => 'Enter your registered email';

  @override
  String get send => 'Send';

  @override
  String get resetEmailSent => 'Password reset email sent.';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get googleLoginFailed => 'Google login failed. Please try again.';

  @override
  String get firebaseUserNotFound => 'No account found with this email.';

  @override
  String get firebaseWrongPassword => 'Incorrect password.';

  @override
  String get firebaseInvalidEmail => 'Invalid email format.';

  @override
  String get firebaseUserDisabled => 'This account has been disabled.';

  @override
  String get firebaseTooManyRequests =>
      'Too many requests. Please try again later.';

  @override
  String get firebaseInvalidCredential => 'Invalid email or password.';

  @override
  String get firebaseNetworkError => 'Please check your network connection.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get signUpFailed => 'Sign up failed. Please try again.';

  @override
  String get googleSignUpFailed => 'Google sign up failed. Please try again.';

  @override
  String get firebaseEmailInUse => 'This email is already in use.';

  @override
  String get firebaseWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get firebaseOperationNotAllowed =>
      'Email/password sign up is disabled.';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get notificationPermissionDesc =>
      'Permission required for reminder notifications';

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get permissionGranted => 'Notification permission granted';

  @override
  String get permissionDenied => 'Notification permission denied';

  @override
  String get sync => 'Sync';

  @override
  String get syncDisabledMessage => 'Log in to enable sync';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncPending => 'Pending Sync';

  @override
  String syncPendingCount(int count) {
    return '$count items not synced';
  }

  @override
  String get syncIdle => 'Synced';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncError => 'Sync Error';

  @override
  String get syncOffline => 'Offline';

  @override
  String get account => 'Account';

  @override
  String get loginPrompt => 'Log in to sync your data';

  @override
  String get user => 'User';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get emailNotVerified => 'Email not verified';

  @override
  String get emailNotVerifiedDesc => 'Please verify your email address.';

  @override
  String get sendVerificationEmail => 'Send Verification Email';

  @override
  String get verificationEmailSent =>
      'Verification email sent. Check your inbox.';

  @override
  String get checkVerification => 'Check Verification Status';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get emailNotYetVerified => 'Email not yet verified. Check your inbox.';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get anonymousUser => 'Anonymous User';

  @override
  String get anonymousDesc => 'Sign in to sync your data across devices';

  @override
  String get upgradeAccount => 'Upgrade Account';

  @override
  String get upgradeAccountDesc =>
      'Link an email or Google account to keep your data';

  @override
  String get linkEmail => 'Link Email Account';

  @override
  String get linkGoogle => 'Link Google Account';

  @override
  String get linkEmailTitle => 'Link Email Account';

  @override
  String get accountLinked => 'Account linked successfully!';

  @override
  String get accountLinkFailed => 'Failed to link account. Please try again.';

  @override
  String get firebaseCredentialInUse =>
      'This credential is already linked to another account.';

  @override
  String get firebaseProviderAlreadyLinked =>
      'This provider is already linked.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteAccountWarning =>
      'All your data will be permanently deleted.';

  @override
  String get reauthRequired => 'Please sign in again to confirm.';

  @override
  String get accountDeleted => 'Account deleted successfully.';

  @override
  String get deleteAccountFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get deleting => 'Deleting...';

  @override
  String get minutesBefore => ' min before';

  @override
  String get hourBefore => ' hour before';

  @override
  String get dayBefore => ' day before';

  @override
  String get customTime => 'Custom time';

  @override
  String get emptyInProgress => 'No tasks in progress';

  @override
  String get emptyCompleted => 'No completed tasks';

  @override
  String get relativeToday => 'Today';

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String relativeDaysAgo(int days) {
    return '$days days ago';
  }
}
