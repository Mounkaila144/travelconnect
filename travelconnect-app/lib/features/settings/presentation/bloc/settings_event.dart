import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateNotificationSetting extends SettingsEvent {
  final String key;
  final bool value;

  const UpdateNotificationSetting(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}
