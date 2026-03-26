import '../entities/app_notification.dart';

class NotificationsResult {
  final List<AppNotification> notifications;
  final bool hasMorePages;
  final int currentPage;
  final int total;
  final int unreadCount;

  const NotificationsResult({
    required this.notifications,
    required this.hasMorePages,
    required this.currentPage,
    required this.total,
    required this.unreadCount,
  });
}

abstract class NotificationsRepository {
  Future<NotificationsResult> getNotifications({int page = 1});
  Future<void> markAsRead(String notificationId);
  Future<int> markAllAsRead();
  Future<int> getUnreadCount();
}
