import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(const NotificationInitial()) {
    on<PermissionRequested>(_onPermissionRequested);
    on<TokenReceived>(_onTokenReceived);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _onPermissionRequested(
    PermissionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final granted = await _notificationService.requestPermission();

      if (granted) {
        emit(const PermissionGranted());

        // Get and register token
        final token = await _notificationService.getFcmToken();
        if (token != null) {
          await _notificationService.registerTokenWithBackend(token);
          emit(TokenRegistered(token));
        }
      } else {
        emit(const PermissionDenied());
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onTokenReceived(
    TokenReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationService.registerTokenWithBackend(event.token);
      emit(TokenRegistered(event.token));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Notification received - state can be used by UI to update badge count, etc.
  }
}
