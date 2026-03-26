import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationsCenterState extends Equatable {
  const NotificationsCenterState();

  @override
  List<Object?> get props => [];
}

class NotificationsCenterInitial extends NotificationsCenterState {
  const NotificationsCenterInitial();
}

class NotificationsCenterLoading extends NotificationsCenterState {
  const NotificationsCenterLoading();
}

class NotificationsCenterLoaded extends NotificationsCenterState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationsCenterLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, currentPage];

  NotificationsCenterLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationsCenterLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NotificationsCenterError extends NotificationsCenterState {
  final String message;

  const NotificationsCenterError(this.message);

  @override
  List<Object?> get props => [message];
}
