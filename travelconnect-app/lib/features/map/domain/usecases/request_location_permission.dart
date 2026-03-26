import '../repositories/location_repository.dart';

class RequestLocationPermission {
  final LocationRepository repository;

  const RequestLocationPermission(this.repository);

  Future<LocationPermissionStatus> call() => repository.requestPermission();
}
