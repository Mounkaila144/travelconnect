import '../entities/map_position.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedPermanently,
  serviceDisabled,
}

abstract class LocationRepository {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<MapPosition> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}
