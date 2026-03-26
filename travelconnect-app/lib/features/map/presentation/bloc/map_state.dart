import 'package:equatable/equatable.dart';

import '../../../questions/domain/entities/question.dart';
import '../../domain/entities/map_position.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final MapPosition currentPosition;
  final bool hasLocationPermission;
  final bool isMovingToLocation;
  final List<Question> questions;
  final bool isLoadingQuestions;
  final bool hasMoreQuestions;
  final int currentQuestionsPage;
  final String? questionsError;

  const MapLoaded({
    required this.currentPosition,
    required this.hasLocationPermission,
    this.isMovingToLocation = false,
    this.questions = const [],
    this.isLoadingQuestions = false,
    this.hasMoreQuestions = false,
    this.currentQuestionsPage = 1,
    this.questionsError,
  });

  MapLoaded copyWith({
    MapPosition? currentPosition,
    bool? hasLocationPermission,
    bool? isMovingToLocation,
    List<Question>? questions,
    bool? isLoadingQuestions,
    bool? hasMoreQuestions,
    int? currentQuestionsPage,
    String? questionsError,
    bool clearError = false,
  }) {
    return MapLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isMovingToLocation: isMovingToLocation ?? this.isMovingToLocation,
      questions: questions ?? this.questions,
      isLoadingQuestions: isLoadingQuestions ?? this.isLoadingQuestions,
      hasMoreQuestions: hasMoreQuestions ?? this.hasMoreQuestions,
      currentQuestionsPage:
          currentQuestionsPage ?? this.currentQuestionsPage,
      questionsError:
          clearError ? null : (questionsError ?? this.questionsError),
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        hasLocationPermission,
        isMovingToLocation,
        questions,
        isLoadingQuestions,
        hasMoreQuestions,
        currentQuestionsPage,
        questionsError,
      ];
}

class LocationPermissionDenied extends MapState {
  final MapPosition defaultPosition;

  const LocationPermissionDenied(this.defaultPosition);

  @override
  List<Object?> get props => [defaultPosition];
}

class LocationPermissionDeniedPermanently extends MapState {
  final MapPosition defaultPosition;

  const LocationPermissionDeniedPermanently(this.defaultPosition);

  @override
  List<Object?> get props => [defaultPosition];
}

enum LocationPermissionRequiredReason {
  denied,
  deniedPermanently,
  serviceDisabled,
}

class LocationPermissionRequired extends MapState {
  final LocationPermissionRequiredReason reason;

  const LocationPermissionRequired({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class MapError extends MapState {
  final String message;
  final MapPosition? fallbackPosition;

  const MapError(this.message, {this.fallbackPosition});

  @override
  List<Object?> get props => [message, fallbackPosition];
}
