import '../entities/map_position.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  const GetCurrentLocation(this.repository);

  Future<MapPosition> call() => repository.getCurrentLocation();
}
