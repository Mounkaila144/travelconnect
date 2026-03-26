import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'notification_zone_event.dart';
import 'notification_zone_state.dart';

class NotificationZoneBloc
    extends Bloc<NotificationZoneEvent, NotificationZoneState> {
  final SettingsRepository settingsRepository;

  NotificationZoneBloc({required this.settingsRepository})
      : super(const NotificationZoneInitial()) {
    on<LoadNotificationZone>(_onLoadZone);
    on<SaveNotificationZone>(_onSaveZone);
  }

  Future<void> _onLoadZone(
    LoadNotificationZone event,
    Emitter<NotificationZoneState> emit,
  ) async {
    emit(const NotificationZoneLoading());
    try {
      final zone = await settingsRepository.getNotificationZone();
      emit(NotificationZoneLoaded(
        latitude: zone['latitude'] as double?,
        longitude: zone['longitude'] as double?,
        radiusKm: zone['radius_km'] as int?,
      ));
    } catch (e) {
      emit(const NotificationZoneError(
          'Erreur de chargement de la zone'));
    }
  }

  Future<void> _onSaveZone(
    SaveNotificationZone event,
    Emitter<NotificationZoneState> emit,
  ) async {
    emit(const NotificationZoneSaving());
    try {
      await settingsRepository.setNotificationZone(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      );
      emit(const NotificationZoneSaved());
    } catch (e) {
      emit(const NotificationZoneError(
          'Erreur d\'enregistrement de la zone'));
    }
  }
}
