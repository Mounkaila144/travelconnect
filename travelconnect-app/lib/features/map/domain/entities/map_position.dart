import 'package:equatable/equatable.dart';

class MapPosition extends Equatable {
  final double latitude;
  final double longitude;
  final double zoom;

  const MapPosition({
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
  });

  const MapPosition.tokyo()
      : latitude = 35.6762,
        longitude = 139.6503,
        zoom = 12.0;

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}
