import '../../domain/entities/map_position.dart';

class MapPositionModel extends MapPosition {
  const MapPositionModel({
    required super.latitude,
    required super.longitude,
    super.zoom,
  });

  factory MapPositionModel.fromJson(Map<String, dynamic> json) {
    return MapPositionModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoom: (json['zoom'] as num?)?.toDouble() ?? 14.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'zoom': zoom,
    };
  }

  factory MapPositionModel.fromEntity(MapPosition entity) {
    return MapPositionModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      zoom: entity.zoom,
    );
  }
}
