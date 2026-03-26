import 'package:equatable/equatable.dart';

abstract class NotificationZoneEvent extends Equatable {
  const NotificationZoneEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationZone extends NotificationZoneEvent {
  const LoadNotificationZone();
}

class SaveNotificationZone extends NotificationZoneEvent {
  final double latitude;
  final double longitude;
  final int radiusKm;

  const SaveNotificationZone({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}
