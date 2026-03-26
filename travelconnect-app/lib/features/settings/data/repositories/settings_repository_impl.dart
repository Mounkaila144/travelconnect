import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    return await remoteDataSource.getNotificationSettings();
  }

  @override
  Future<Map<String, bool>> updateNotificationSettings(
      Map<String, bool> settings) async {
    return await remoteDataSource.updateNotificationSettings(settings);
  }

  @override
  Future<Map<String, dynamic>> getNotificationZone() async {
    return await remoteDataSource.getNotificationZone();
  }

  @override
  Future<void> setNotificationZone({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    await remoteDataSource.setNotificationZone(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
