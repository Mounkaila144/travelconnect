import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notifications_repository.dart';
import 'notifications_center_event.dart';
import 'notifications_center_state.dart';

class NotificationsCenterBloc
    extends Bloc<NotificationsCenterEvent, NotificationsCenterState> {
  final NotificationsRepository notificationsRepository;

  NotificationsCenterBloc({required this.notificationsRepository})
      : super(const NotificationsCenterInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<UpdateUnreadCount>(_onUpdateUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsCenterState> emit,
  ) async {
    emit(const NotificationsCenterLoading());
    try {
      final result = await notificationsRepository.getNotifications(page: 1);
      emit(NotificationsCenterLoaded(
        notifications: result.notifications,
        unreadCount: result.unreadCount,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
      ));
    } catch (e, stackTrace) {
      debugPrint('[NOTIFICATIONS] Error loading notifications: $e');
      debugPrint('[NOTIFICATIONS] Stack trace: $stackTrace');
      emit(const NotificationsCenterError(
          'Impossible de charger les notifications'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsCenterState> emit,
  ) async {
    try {
      final result = await notificationsRepository.getNotifications(page: 1);
      emit(NotificationsCenterLoaded(
        notifications: result.notifications,
        unreadCount: result.unreadCount,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
      ));
    } catch (e) {
      emit(const NotificationsCenterError(
          'Erreur de rafraîchissement'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationsCenterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsCenterLoaded) return;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == event.notification.id) {
        return n.markAsRead();
      }
      return n;
    }).toList();

    final newUnreadCount =
        event.notification.isUnread
            ? currentState.unreadCount - 1
            : currentState.unreadCount;

    emit(currentState.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount.clamp(0, 999),
    ));

    try {
      await notificationsRepository.markAsRead(event.notification.id);
    } catch (e) {
      // Revert on failure
      emit(currentState);
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationsCenterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsCenterLoaded) return;

    // Optimistic update
    final updatedNotifications =
        currentState.notifications.map((n) => n.markAsRead()).toList();
    emit(currentState.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    ));

    try {
      await notificationsRepository.markAllAsRead();
    } catch (e) {
      // Revert on failure
      emit(currentState);
    }
  }

  void _onUpdateUnreadCount(
    UpdateUnreadCount event,
    Emitter<NotificationsCenterState> emit,
  ) {
    final currentState = state;
    if (currentState is NotificationsCenterLoaded) {
      emit(currentState.copyWith(unreadCount: event.count));
    }
  }
}
