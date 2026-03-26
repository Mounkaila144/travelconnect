import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationsCenterEvent extends Equatable {
  const NotificationsCenterEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsCenterEvent {
  const LoadNotifications();
}

class RefreshNotifications extends NotificationsCenterEvent {
  const RefreshNotifications();
}

class MarkAsRead extends NotificationsCenterEvent {
  final AppNotification notification;

  const MarkAsRead(this.notification);

  @override
  List<Object?> get props => [notification];
}

class MarkAllAsRead extends NotificationsCenterEvent {
  const MarkAllAsRead();
}

class UpdateUnreadCount extends NotificationsCenterEvent {
  final int count;

  const UpdateUnreadCount(this.count);

  @override
  List<Object?> get props => [count];
}
