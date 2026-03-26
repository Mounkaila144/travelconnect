import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends MapEvent {
  const InitializeMap();
}

class RequestLocationPermission extends MapEvent {
  const RequestLocationPermission();
}

class GetCurrentLocation extends MapEvent {
  const GetCurrentLocation();
}

class MoveToMyLocation extends MapEvent {
  const MoveToMyLocation();
}

class MapMoved extends MapEvent {
  final CameraPosition position;

  const MapMoved(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdateCameraPosition extends MapEvent {
  final CameraPosition position;

  const UpdateCameraPosition(this.position);

  @override
  List<Object?> get props => [position];
}

class LoadQuestionsInView extends MapEvent {
  final double latitude;
  final double longitude;
  final int radiusKm;

  const LoadQuestionsInView({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

class RefreshQuestions extends MapEvent {
  const RefreshQuestions();
}

class LoadMoreQuestions extends MapEvent {
  const LoadMoreQuestions();
}

class AddQuestionToMap extends MapEvent {
  final dynamic question;

  const AddQuestionToMap(this.question);

  @override
  List<Object?> get props => [question];
}
