import '../../domain/entities/map_position.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource localDataSource;

  const LocationRepositoryImpl({required this.localDataSource});

  @override
  Future<LocationPermissionStatus> checkPermission() {
    return localDataSource.checkPermission();
  }

  @override
  Future<LocationPermissionStatus> requestPermission() {
    return localDataSource.requestPermission();
  }

  @override
  Future<MapPosition> getCurrentLocation() {
    return localDataSource.getCurrentLocation();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return localDataSource.isLocationServiceEnabled();
  }

  @override
  Future<bool> openAppSettings() {
    return localDataSource.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return localDataSource.openLocationSettings();
  }
}
