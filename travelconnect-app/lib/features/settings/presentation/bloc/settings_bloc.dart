import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository})
      : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateNotificationSetting>(_onUpdateNotificationSetting);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await settingsRepository.getNotificationSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(const SettingsError('Impossible de charger les paramètres'));
    }
  }

  Future<void> _onUpdateNotificationSetting(
    UpdateNotificationSetting event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // Optimistic update
    final updatedSettings =
        Map<String, bool>.from(currentState.settings);
    updatedSettings[event.key] = event.value;
    emit(SettingsLoaded(updatedSettings));

    try {
      final serverSettings =
          await settingsRepository.updateNotificationSettings(
        {event.key: event.value},
      );
      emit(SettingsLoaded(serverSettings));
    } catch (e) {
      // Revert on failure
      emit(SettingsLoaded(currentState.settings));
      emit(const SettingsError('Impossible de mettre à jour les paramètres'));
      emit(SettingsLoaded(currentState.settings));
    }
  }
}
