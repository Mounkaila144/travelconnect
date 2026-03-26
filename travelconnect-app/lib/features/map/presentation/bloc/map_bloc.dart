import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../questions/domain/entities/question.dart';
import '../../../questions/domain/usecases/get_nearby_questions.dart';
import '../../domain/entities/map_position.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/check_location_permission.dart';
import '../../domain/usecases/get_current_location.dart' as uc;
import '../../domain/usecases/request_location_permission.dart' as uc;
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final uc.GetCurrentLocation getCurrentLocation;
  final CheckLocationPermission checkLocationPermission;
  final uc.RequestLocationPermission requestLocationPermission;
  final GetNearbyQuestions getNearbyQuestions;

  Timer? _questionsDebounce;

  // Track last load params to avoid duplicate requests
  double? _lastLoadLat;
  double? _lastLoadLng;
  int? _lastLoadRadius;

  MapBloc({
    required this.getCurrentLocation,
    required this.checkLocationPermission,
    required this.requestLocationPermission,
    required this.getNearbyQuestions,
  }) : super(const MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<MoveToMyLocation>(_onMoveToMyLocation);
    on<MapMoved>(_onMapMoved);
    on<UpdateCameraPosition>(_onUpdateCameraPosition);
    on<LoadQuestionsInView>(_onLoadQuestionsInView);
    on<RefreshQuestions>(_onRefreshQuestions);
    on<LoadMoreQuestions>(_onLoadMoreQuestions);
    on<AddQuestionToMap>(_onAddQuestionToMap);
  }

  @override
  Future<void> close() {
    _questionsDebounce?.cancel();
    return super.close();
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    final stopwatch = Stopwatch()..start();

    try {
      final permissionStatus = await checkLocationPermission();

      switch (permissionStatus) {
        case LocationPermissionStatus.granted:
          final position = await getCurrentLocation();
          emit(MapLoaded(
            currentPosition: position,
            hasLocationPermission: true,
          ));
          break;

        case LocationPermissionStatus.denied:
          final requestResult = await requestLocationPermission();
          if (requestResult == LocationPermissionStatus.granted) {
            final position = await getCurrentLocation();
            emit(MapLoaded(
              currentPosition: position,
              hasLocationPermission: true,
            ));
          } else if (requestResult ==
              LocationPermissionStatus.deniedPermanently) {
            emit(const LocationPermissionRequired(
              reason: LocationPermissionRequiredReason.deniedPermanently,
            ));
          } else {
            emit(const LocationPermissionRequired(
              reason: LocationPermissionRequiredReason.denied,
            ));
          }
          break;

        case LocationPermissionStatus.deniedPermanently:
          emit(const LocationPermissionRequired(
            reason: LocationPermissionRequiredReason.deniedPermanently,
          ));
          break;

        case LocationPermissionStatus.serviceDisabled:
          emit(const LocationPermissionRequired(
            reason: LocationPermissionRequiredReason.serviceDisabled,
          ));
          break;
      }
    } catch (e) {
      emit(const MapError(
        'Erreur de chargement de la carte. Veuillez réessayer.',
      ));
    }

    stopwatch.stop();
    if (kDebugMode) {
      debugPrint('Map initialized in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    final result = await requestLocationPermission();
    if (result == LocationPermissionStatus.granted) {
      final position = await getCurrentLocation();
      emit(MapLoaded(
        currentPosition: position,
        hasLocationPermission: true,
      ));
    } else if (result == LocationPermissionStatus.deniedPermanently) {
      emit(const LocationPermissionRequired(
        reason: LocationPermissionRequiredReason.deniedPermanently,
      ));
    } else if (result == LocationPermissionStatus.serviceDisabled) {
      emit(const LocationPermissionRequired(
        reason: LocationPermissionRequiredReason.serviceDisabled,
      ));
    } else {
      emit(const LocationPermissionRequired(
        reason: LocationPermissionRequiredReason.denied,
      ));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<MapState> emit,
  ) async {
    final position = await getCurrentLocation();
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(currentPosition: position));
    } else {
      emit(MapLoaded(
        currentPosition: position,
        hasLocationPermission: true,
      ));
    }
  }

  Future<void> _onMoveToMyLocation(
    MoveToMyLocation event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(isMovingToLocation: true));

      try {
        final position = await getCurrentLocation();
        emit(MapLoaded(
          currentPosition: position,
          hasLocationPermission: true,
          isMovingToLocation: false,
        ));
      } catch (_) {
        emit(currentState.copyWith(isMovingToLocation: false));
      }
    }
  }

  void _onMapMoved(
    MapMoved event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        currentPosition: MapPosition(
          latitude: event.position.target.latitude,
          longitude: event.position.target.longitude,
          zoom: event.position.zoom,
        ),
      ));
    }
  }

  void _onUpdateCameraPosition(
    UpdateCameraPosition event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        currentPosition: MapPosition(
          latitude: event.position.target.latitude,
          longitude: event.position.target.longitude,
          zoom: event.position.zoom,
        ),
      ));
    }
  }

  Future<void> _onLoadQuestionsInView(
    LoadQuestionsInView event,
    Emitter<MapState> emit,
  ) async {
    if (state is! MapLoaded) return;
    final currentState = state as MapLoaded;

    // Skip if same params as last load
    if (_lastLoadLat == event.latitude &&
        _lastLoadLng == event.longitude &&
        _lastLoadRadius == event.radiusKm) {
      return;
    }

    _lastLoadLat = event.latitude;
    _lastLoadLng = event.longitude;
    _lastLoadRadius = event.radiusKm;

    emit(currentState.copyWith(
      isLoadingQuestions: true,
      clearError: true,
    ));

    try {
      final result = await getNearbyQuestions(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      );

      if (state is! MapLoaded) return;

      emit((state as MapLoaded).copyWith(
        questions: result.questions,
        isLoadingQuestions: false,
        hasMoreQuestions: result.hasMorePages,
        currentQuestionsPage: result.currentPage,
        clearError: true,
      ));
    } catch (e) {
      if (state is! MapLoaded) return;

      if (kDebugMode) {
        debugPrint('Error loading questions: $e');
      }

      emit((state as MapLoaded).copyWith(
        isLoadingQuestions: false,
        questionsError:
            'Impossible de charger les questions. Vérifiez votre connexion.',
      ));
    }
  }

  Future<void> _onRefreshQuestions(
    RefreshQuestions event,
    Emitter<MapState> emit,
  ) async {
    // Reset last load params to force reload
    _lastLoadLat = null;
    _lastLoadLng = null;
    _lastLoadRadius = null;

    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      add(LoadQuestionsInView(
        latitude: currentState.currentPosition.latitude,
        longitude: currentState.currentPosition.longitude,
        radiusKm: calculateRadiusFromZoom(currentState.currentPosition.zoom),
      ));
    }
  }

  Future<void> _onLoadMoreQuestions(
    LoadMoreQuestions event,
    Emitter<MapState> emit,
  ) async {
    if (state is! MapLoaded) return;
    final currentState = state as MapLoaded;

    if (!currentState.hasMoreQuestions || currentState.isLoadingQuestions) {
      return;
    }

    emit(currentState.copyWith(isLoadingQuestions: true));

    try {
      final nextPage = currentState.currentQuestionsPage + 1;
      final result = await getNearbyQuestions(
        latitude: currentState.currentPosition.latitude,
        longitude: currentState.currentPosition.longitude,
        radiusKm: calculateRadiusFromZoom(currentState.currentPosition.zoom),
        page: nextPage,
      );

      if (state is! MapLoaded) return;

      final allQuestions = [
        ...(state as MapLoaded).questions,
        ...result.questions,
      ];

      emit((state as MapLoaded).copyWith(
        questions: allQuestions,
        isLoadingQuestions: false,
        hasMoreQuestions: result.hasMorePages,
        currentQuestionsPage: result.currentPage,
      ));
    } catch (e) {
      if (state is! MapLoaded) return;

      emit((state as MapLoaded).copyWith(
        isLoadingQuestions: false,
        questionsError:
            'Impossible de charger plus de questions.',
      ));
    }
  }

  void _onAddQuestionToMap(
    AddQuestionToMap event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapLoaded) return;
    final currentState = state as MapLoaded;
    final question = event.question as Question;

    final updatedQuestions = [question, ...currentState.questions];
    emit(currentState.copyWith(questions: updatedQuestions));
  }

  static int calculateRadiusFromZoom(double zoom) {
    // Approximate radius in km based on zoom level
    if (zoom >= 17) return 1;
    if (zoom >= 15) return 3;
    if (zoom >= 13) return 10;
    if (zoom >= 11) return 25;
    return 50;
  }
}
