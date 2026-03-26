import 'package:dio/dio.dart';

abstract class SettingsRemoteDataSource {
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

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    final response = await dio.get('/user/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    final settings = data['notification_settings'] as Map<String, dynamic>?;
    return {
      'new_answers': settings?['new_answers'] as bool? ?? true,
      'nearby_questions': settings?['nearby_questions'] as bool? ?? true,
    };
  }

  @override
  Future<Map<String, bool>> updateNotificationSettings(
      Map<String, bool> settings) async {
    final response =
        await dio.put('/user/notification-settings', data: settings);
    final data = response.data as Map<String, dynamic>;
    return {
      'new_answers': data['new_answers'] as bool? ?? true,
      'nearby_questions': data['nearby_questions'] as bool? ?? true,
    };
  }

  @override
  Future<Map<String, dynamic>> getNotificationZone() async {
    final response = await dio.get('/user/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return {
      'latitude': data['notification_zone_lat'] != null
          ? (data['notification_zone_lat'] as num).toDouble()
          : null,
      'longitude': data['notification_zone_lng'] != null
          ? (data['notification_zone_lng'] as num).toDouble()
          : null,
      'radius_km': data['notification_zone_radius'] as int?,
    };
  }

  @override
  Future<void> setNotificationZone({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    await dio.put('/user/notification-zone', data: {
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
    });
  }
}
