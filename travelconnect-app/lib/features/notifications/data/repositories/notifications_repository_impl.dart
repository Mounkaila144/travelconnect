import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationsResult> getNotifications({int page = 1}) async {
    final response = await remoteDataSource.getNotifications(page: page);

    return NotificationsResult(
      notifications:
          response.notifications.map((model) => model.toEntity()).toList(),
      hasMorePages: response.hasMorePages,
      currentPage: response.currentPage,
      total: response.total,
      unreadCount: response.unreadCount,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<int> markAllAsRead() async {
    return await remoteDataSource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDataSource.getUnreadCount();
  }
}
