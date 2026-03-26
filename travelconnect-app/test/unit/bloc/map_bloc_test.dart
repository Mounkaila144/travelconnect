import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/map/domain/entities/map_position.dart';
import 'package:travelconnect_app/features/map/domain/repositories/location_repository.dart';
import 'package:travelconnect_app/features/map/domain/usecases/check_location_permission.dart';
import 'package:travelconnect_app/features/map/domain/usecases/get_current_location.dart'
    as uc;
import 'package:travelconnect_app/features/map/domain/usecases/request_location_permission.dart'
    as uc;
import 'package:travelconnect_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:travelconnect_app/features/map/presentation/bloc/map_event.dart';
import 'package:travelconnect_app/features/map/presentation/bloc/map_state.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/domain/repositories/questions_repository.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/get_nearby_questions.dart';

class MockGetCurrentLocation extends Mock implements uc.GetCurrentLocation {}

class MockCheckLocationPermission extends Mock
    implements CheckLocationPermission {}

class MockRequestLocationPermission extends Mock
    implements uc.RequestLocationPermission {}

class MockGetNearbyQuestions extends Mock implements GetNearbyQuestions {}

void main() {
  late MapBloc mapBloc;
  late MockGetCurrentLocation mockGetCurrentLocation;
  late MockCheckLocationPermission mockCheckPermission;
  late MockRequestLocationPermission mockRequestPermission;
  late MockGetNearbyQuestions mockGetNearbyQuestions;

  setUp(() {
    mockGetCurrentLocation = MockGetCurrentLocation();
    mockCheckPermission = MockCheckLocationPermission();
    mockRequestPermission = MockRequestLocationPermission();
    mockGetNearbyQuestions = MockGetNearbyQuestions();
    mapBloc = MapBloc(
      getCurrentLocation: mockGetCurrentLocation,
      checkLocationPermission: mockCheckPermission,
      requestLocationPermission: mockRequestPermission,
      getNearbyQuestions: mockGetNearbyQuestions,
    );
  });

  tearDown(() {
    mapBloc.close();
  });

  group('MapBloc - Location', () {
    test('initial state is MapInitial', () {
      expect(mapBloc.state, const MapInitial());
    });

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapLoaded] when InitializeMap succeeds with granted permission',
      build: () {
        when(() => mockCheckPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => mockGetCurrentLocation()).thenAnswer(
          (_) async => const MapPosition(
            latitude: 35.6762,
            longitude: 139.6503,
            zoom: 15.0,
          ),
        );
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<MapLoaded>()
            .having((s) => s.currentPosition.latitude, 'latitude', 35.6762)
            .having((s) => s.hasLocationPermission, 'permission', true),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, LocationPermissionDenied] when permission is denied',
      build: () {
        when(() => mockCheckPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        when(() => mockRequestPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<LocationPermissionDenied>()
            .having((s) => s.defaultPosition.latitude, 'lat', 35.6762)
            .having((s) => s.defaultPosition.longitude, 'lng', 139.6503),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits LocationPermissionDeniedPermanently when permission permanently denied',
      build: () {
        when(() => mockCheckPermission()).thenAnswer(
            (_) async => LocationPermissionStatus.deniedPermanently);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<LocationPermissionDeniedPermanently>()
            .having((s) => s.defaultPosition.latitude, 'lat', 35.6762),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits MapError when location service is disabled',
      build: () {
        when(() => mockCheckPermission())
            .thenAnswer((_) async => LocationPermissionStatus.serviceDisabled);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<MapError>().having(
          (s) => s.fallbackPosition?.latitude,
          'fallback lat',
          35.6762,
        ),
      ],
    );

    blocTest<MapBloc, MapState>(
      'MoveToMyLocation updates position when in MapLoaded state',
      build: () {
        when(() => mockGetCurrentLocation()).thenAnswer(
          (_) async => const MapPosition(
            latitude: 34.0522,
            longitude: -118.2437,
            zoom: 15.0,
          ),
        );
        return mapBloc;
      },
      seed: () => const MapLoaded(
        currentPosition: MapPosition(
          latitude: 35.6762,
          longitude: 139.6503,
          zoom: 14.0,
        ),
        hasLocationPermission: true,
      ),
      act: (bloc) => bloc.add(const MoveToMyLocation()),
      expect: () => [
        isA<MapLoaded>()
            .having((s) => s.isMovingToLocation, 'isMoving', true),
        isA<MapLoaded>()
            .having((s) => s.currentPosition.latitude, 'lat', 34.0522)
            .having((s) => s.currentPosition.longitude, 'lng', -118.2437)
            .having((s) => s.isMovingToLocation, 'isMoving', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'default Tokyo location is used when permission denied',
      build: () {
        when(() => mockCheckPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        when(() => mockRequestPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<LocationPermissionDenied>()
            .having((s) => s.defaultPosition.latitude, 'lat', 35.6762)
            .having((s) => s.defaultPosition.longitude, 'lng', 139.6503),
      ],
    );

    blocTest<MapBloc, MapState>(
      'denied then request grants emits MapLoaded',
      build: () {
        when(() => mockCheckPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        when(() => mockRequestPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => mockGetCurrentLocation()).thenAnswer(
          (_) async => const MapPosition(
            latitude: 48.8566,
            longitude: 2.3522,
            zoom: 15.0,
          ),
        );
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        const MapLoading(),
        isA<MapLoaded>()
            .having((s) => s.currentPosition.latitude, 'lat', 48.8566)
            .having((s) => s.hasLocationPermission, 'permission', true),
      ],
    );
  });

  group('MapBloc - Load Questions', () {
    final testQuestions = [
      Question(
        id: 1,
        title: 'Test Question 1',
        latitude: 35.6762,
        longitude: 139.6503,
        answersCount: 3,
        createdAt: DateTime(2026, 1, 31),
      ),
      Question(
        id: 2,
        title: 'Test Question 2',
        latitude: 35.6800,
        longitude: 139.6600,
        answersCount: 0,
        createdAt: DateTime(2026, 1, 30),
      ),
    ];

    blocTest<MapBloc, MapState>(
      'emits MapLoaded with questions when LoadQuestionsInView succeeds',
      build: () {
        when(() => mockGetNearbyQuestions(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
              page: any(named: 'page'),
            )).thenAnswer(
          (_) async => QuestionsResult(
            questions: testQuestions,
            hasMorePages: false,
            currentPage: 1,
            total: 2,
          ),
        );
        return mapBloc;
      },
      seed: () => const MapLoaded(
        currentPosition: MapPosition(
          latitude: 35.6762,
          longitude: 139.6503,
          zoom: 14.0,
        ),
        hasLocationPermission: true,
      ),
      act: (bloc) => bloc.add(const LoadQuestionsInView(
        latitude: 35.6762,
        longitude: 139.6503,
        radiusKm: 10,
      )),
      expect: () => [
        isA<MapLoaded>()
            .having((s) => s.isLoadingQuestions, 'loading', true),
        isA<MapLoaded>()
            .having((s) => s.questions.length, 'questions count', 2)
            .having((s) => s.questions.first.title, 'title', 'Test Question 1')
            .having((s) => s.isLoadingQuestions, 'loading', false)
            .having((s) => s.hasMoreQuestions, 'hasMore', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits error state when LoadQuestionsInView fails',
      build: () {
        when(() => mockGetNearbyQuestions(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
              page: any(named: 'page'),
            )).thenThrow(Exception('Network error'));
        return mapBloc;
      },
      seed: () => const MapLoaded(
        currentPosition: MapPosition(
          latitude: 35.6762,
          longitude: 139.6503,
          zoom: 14.0,
        ),
        hasLocationPermission: true,
      ),
      act: (bloc) => bloc.add(const LoadQuestionsInView(
        latitude: 35.6762,
        longitude: 139.6503,
        radiusKm: 10,
      )),
      expect: () => [
        isA<MapLoaded>()
            .having((s) => s.isLoadingQuestions, 'loading', true),
        isA<MapLoaded>()
            .having((s) => s.isLoadingQuestions, 'loading', false)
            .having((s) => s.questionsError, 'error', isNotNull),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits MapLoaded with more questions when LoadMoreQuestions succeeds',
      build: () {
        when(() => mockGetNearbyQuestions(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
              page: any(named: 'page'),
            )).thenAnswer(
          (_) async => QuestionsResult(
            questions: [
              Question(
                id: 3,
                title: 'Page 2 Question',
                latitude: 35.6762,
                longitude: 139.6503,
                answersCount: 1,
                createdAt: DateTime(2026, 1, 29),
              ),
            ],
            hasMorePages: false,
            currentPage: 2,
            total: 3,
          ),
        );
        return mapBloc;
      },
      seed: () => MapLoaded(
        currentPosition: const MapPosition(
          latitude: 35.6762,
          longitude: 139.6503,
          zoom: 14.0,
        ),
        hasLocationPermission: true,
        questions: testQuestions,
        hasMoreQuestions: true,
        currentQuestionsPage: 1,
      ),
      act: (bloc) => bloc.add(const LoadMoreQuestions()),
      expect: () => [
        isA<MapLoaded>()
            .having((s) => s.isLoadingQuestions, 'loading', true),
        isA<MapLoaded>()
            .having((s) => s.questions.length, 'total questions', 3)
            .having((s) => s.hasMoreQuestions, 'hasMore', false)
            .having((s) => s.currentQuestionsPage, 'page', 2),
      ],
    );

    blocTest<MapBloc, MapState>(
      'does not load more when no more pages available',
      build: () => mapBloc,
      seed: () => MapLoaded(
        currentPosition: const MapPosition(
          latitude: 35.6762,
          longitude: 139.6503,
          zoom: 14.0,
        ),
        hasLocationPermission: true,
        questions: testQuestions,
        hasMoreQuestions: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreQuestions()),
      expect: () => [],
    );

    test('calculateRadiusFromZoom returns correct values', () {
      expect(MapBloc.calculateRadiusFromZoom(18), 1);
      expect(MapBloc.calculateRadiusFromZoom(17), 1);
      expect(MapBloc.calculateRadiusFromZoom(16), 3);
      expect(MapBloc.calculateRadiusFromZoom(15), 3);
      expect(MapBloc.calculateRadiusFromZoom(14), 10);
      expect(MapBloc.calculateRadiusFromZoom(13), 10);
      expect(MapBloc.calculateRadiusFromZoom(12), 25);
      expect(MapBloc.calculateRadiusFromZoom(10), 50);
    });
  });
}
