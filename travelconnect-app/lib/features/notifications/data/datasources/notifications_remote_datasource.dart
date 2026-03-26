import 'package:dio/dio.dart';

import '../models/notification_model.dart';

class NotificationsResponse {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final int unreadCount;

  const NotificationsResponse({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.unreadCount,
  });

  bool get hasMorePages => currentPage < lastPage;
}

abstract class NotificationsRemoteDataSource {
  Future<NotificationsResponse> getNotifications({int page = 1});
  Future<void> markAsRead(String notificationId);
  Future<int> markAllAsRead();
  Future<int> getUnreadCount();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<NotificationsResponse> getNotifications({int page = 1}) async {
    final response = await dio.get('/notifications', queryParameters: {
      'page': page,
    });

    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    return NotificationsResponse(
      notifications: data
          .map((item) =>
              NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await dio.post('/notifications/$notificationId/read');
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await dio.post('/notifications/read-all');
    final json = response.data as Map<String, dynamic>;
    return json['marked_count'] as int? ?? 0;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await dio.get('/notifications/unread-count');
    final json = response.data as Map<String, dynamic>;
    return json['unread_count'] as int? ?? 0;
  }
}
