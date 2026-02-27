class FirestorePaths {
  static String tasksCol(String userId) => 'users/$userId/tasks';
  static String taskDoc(String userId, String taskId) =>
      'users/$userId/tasks/$taskId';
  static String userDoc(String userId) => 'users/$userId';
  static const String usersCol = 'users';
  static String fcmTokensCol(String userId) => 'users/$userId/fcmTokens';
  static String fcmTokenDoc(String userId, String tokenId) =>
      'users/$userId/fcmTokens/$tokenId';
}
