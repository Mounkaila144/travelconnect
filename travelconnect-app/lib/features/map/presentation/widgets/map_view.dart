import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';
import '../../../questions/domain/entities/question.dart';
import '../../../questions/domain/usecases/create_answer.dart';
import '../../../questions/domain/usecases/get_question_detail.dart';
import '../../../questions/domain/usecases/rate_answer.dart';
import '../../../questions/presentation/bloc/question_detail_bloc.dart';
import '../../../questions/presentation/bloc/question_detail_event.dart';
import '../../../questions/presentation/pages/question_detail_page.dart';
import '../../domain/entities/map_position.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../services/marker_icon_service.dart';

class MapView extends StatefulWidget {
  final MapPosition initialPosition;
  final bool hasLocationPermission;

  const MapView({
    super.key,
    required this.initialPosition,
    required this.hasLocationPermission,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Timer? _debounce;
  Timer? _questionsLoadDebounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _questionsLoadDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.cameraDebounceMs),
      () {
        context.read<MapBloc>().add(MapMoved(position));
      },
    );
  }

  void _onCameraIdle() {
    _questionsLoadDebounce?.cancel();
    _questionsLoadDebounce = Timer(
      const Duration(seconds: 1),
      () {
        _loadQuestionsInViewport();
      },
    );
  }

  void _loadQuestionsInViewport() async {
    if (_mapController == null) return;

    final bounds = await _mapController!.getVisibleRegion();
    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    final zoom = await _mapController!.getZoomLevel();
    final radius = MapBloc.calculateRadiusFromZoom(zoom);

    if (!mounted) return;

    context.read<MapBloc>().add(LoadQuestionsInView(
          latitude: center.latitude,
          longitude: center.longitude,
          radiusKm: radius,
        ));
  }

  Set<Marker> _buildMarkers(List<Question> questions) {
    return questions.map((question) {
      return Marker(
        markerId: MarkerId('question_${question.id}'),
        position: LatLng(question.latitude, question.longitude),
        icon: MarkerIconService.getIcon(question),
        infoWindow: InfoWindow(
          title: question.title,
          snippet: question.needsAnswer
              ? 'Aucune réponse - Soyez le premier !'
              : '${question.answersCount} réponse${question.answersCount > 1 ? 's' : ''}',
          onTap: () => _onMarkerInfoWindowTap(question),
        ),
        zIndex: question.needsAnswer ? 2.0 : 1.0,
      );
    }).toSet();
  }

  void _onMarkerInfoWindowTap(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => QuestionDetailBloc(
            getQuestionDetail: sl<GetQuestionDetail>(),
            createAnswer: sl<CreateAnswer>(),
            rateAnswer: sl<RateAnswer>(),
          )..add(LoadQuestionDetail(question.id)),
          child: QuestionDetailPage(questionId: question.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) {
        if (current is MapLoaded && previous is MapLoaded) {
          return current.isMovingToLocation && !previous.isMovingToLocation;
        }
        return false;
      },
      listener: (context, state) {
        if (state is MapLoaded && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  state.currentPosition.latitude,
                  state.currentPosition.longitude,
                ),
                zoom: AppConstants.myLocationZoom,
              ),
            ),
          );
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        buildWhen: (previous, current) {
          if (current is MapLoaded && previous is MapLoaded) {
            return current.questions != previous.questions;
          }
          return false;
        },
        builder: (context, state) {
          final markers = state is MapLoaded
              ? _buildMarkers(state.questions)
              : <Marker>{};

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialPosition.latitude,
                widget.initialPosition.longitude,
              ),
              zoom: widget.initialPosition.zoom,
            ),
            markers: markers,
            myLocationEnabled: widget.hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              // Load questions after map is created
              _loadQuestionsInViewport();
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          );
        },
      ),
    );
  }
}
