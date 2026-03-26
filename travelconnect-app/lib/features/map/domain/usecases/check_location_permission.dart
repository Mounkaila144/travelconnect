import '../repositories/location_repository.dart';

class CheckLocationPermission {
  final LocationRepository repository;

  const CheckLocationPermission(this.repository);

  Future<LocationPermissionStatus> call() => repository.checkPermission();
}
