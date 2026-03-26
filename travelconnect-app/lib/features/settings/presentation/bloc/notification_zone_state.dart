import 'package:equatable/equatable.dart';

abstract class NotificationZoneState extends Equatable {
  const NotificationZoneState();

  @override
  List<Object?> get props => [];
}

class NotificationZoneInitial extends NotificationZoneState {
  const NotificationZoneInitial();
}

class NotificationZoneLoading extends NotificationZoneState {
  const NotificationZoneLoading();
}

class NotificationZoneLoaded extends NotificationZoneState {
  final double? latitude;
  final double? longitude;
  final int? radiusKm;

  const NotificationZoneLoaded({
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

class NotificationZoneSaving extends NotificationZoneState {
  const NotificationZoneSaving();
}

class NotificationZoneSaved extends NotificationZoneState {
  const NotificationZoneSaved();
}

class NotificationZoneError extends NotificationZoneState {
  final String message;

  const NotificationZoneError(this.message);

  @override
  List<Object?> get props => [message];
}
