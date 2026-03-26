abstract class SettingsRepository {
  Future<Map<String, bool>> getNotificationSettings();
  Future<Map<String, bool>> updateNotificationSettings(
      Map<String, bool> settings);
  Future<Map<String, dynamic>> getNotificationZone();
  Future<void> setNotificationZone({
    required double latitude,
    required double longitude,
    required int radiusKm,
  });
}
