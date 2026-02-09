class FirestorePaths {
  static String tasksCol(String userId) => 'users/$userId/tasks';
  static String taskDoc(String userId, String taskId) =>
      'users/$userId/tasks/$taskId';
}
