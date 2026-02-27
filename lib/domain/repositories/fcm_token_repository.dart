abstract class FcmTokenRepository {
  Future<void> saveToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> deleteToken({required String userId, required String token});

  Future<void> deleteAllTokens(String userId);
}
