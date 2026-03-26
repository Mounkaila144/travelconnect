import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/map/domain/entities/map_position.dart';
import 'package:travelconnect_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:travelconnect_app/features/map/presentation/bloc/map_event.dart';
import 'package:travelconnect_app/features/map/presentation/bloc/map_state.dart';
import 'package:travelconnect_app/features/map/presentation/pages/map_page.dart';
import 'package:travelconnect_app/features/map/presentation/widgets/my_location_button.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

class FakeMapEvent extends Fake implements MapEvent {}

class FakeMapState extends Fake implements MapState {}

Widget makeTestableWidget(Widget child, MapBloc bloc) {
  return MaterialApp(
    home: BlocProvider<MapBloc>.value(
      value: bloc,
      child: child,
    ),
  );
}

void main() {
  late MockMapBloc mockMapBloc;

  setUpAll(() {
    registerFallbackValue(FakeMapEvent());
    registerFallbackValue(FakeMapState());
  });

  setUp(() {
    mockMapBloc = MockMapBloc();
  });

  group('MapPage Widget Tests', () {
    testWidgets('shows loading indicator when state is MapLoading',
        (tester) async {
      when(() => mockMapBloc.state).thenReturn(const MapLoading());

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is MapInitial',
        (tester) async {
      when(() => mockMapBloc.state).thenReturn(const MapInitial());

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows MyLocationButton when map is loaded', (tester) async {
      when(() => mockMapBloc.state).thenReturn(
        const MapLoaded(
          currentPosition: MapPosition(
            latitude: 35.6762,
            longitude: 139.6503,
            zoom: 14.0,
          ),
          hasLocationPermission: true,
        ),
      );

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));

      expect(find.byType(MyLocationButton), findsOneWidget);
    });

    testWidgets('shows permission screen when permission is denied',
        (tester) async {
      whenListen(
        mockMapBloc,
        Stream<MapState>.fromIterable([
          const LocationPermissionRequired(
            reason: LocationPermissionRequiredReason.denied,
          ),
        ]),
        initialState: const MapLoading(),
      );

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));
      await tester.pump();

      expect(find.text('Localisation requise'), findsOneWidget);
      expect(find.text('Autoriser la localisation'), findsOneWidget);
    });

    testWidgets('shows permission screen with settings when permanently denied',
        (tester) async {
      whenListen(
        mockMapBloc,
        Stream<MapState>.fromIterable([
          const LocationPermissionRequired(
            reason: LocationPermissionRequiredReason.deniedPermanently,
          ),
        ]),
        initialState: const MapLoading(),
      );

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));
      await tester.pump();

      expect(find.text('Localisation requise'), findsOneWidget);
      expect(find.text('Ouvrir les paramètres'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('shows error screen with retry button on MapError',
        (tester) async {
      whenListen(
        mockMapBloc,
        Stream<MapState>.fromIterable([
          const MapError(
            'Erreur de chargement de la carte. Veuillez réessayer.',
          ),
        ]),
        initialState: const MapLoading(),
      );

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));
      await tester.pump();

      expect(
        find.text('Erreur de chargement de la carte. Veuillez réessayer.'),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('shows permission screen when service is disabled',
        (tester) async {
      whenListen(
        mockMapBloc,
        Stream<MapState>.fromIterable([
          const LocationPermissionRequired(
            reason: LocationPermissionRequiredReason.serviceDisabled,
          ),
        ]),
        initialState: const MapLoading(),
      );

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));
      await tester.pump();

      expect(
        find.text('Service de localisation désactivé'),
        findsOneWidget,
      );
      expect(find.text('Activer la localisation'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('dispatches InitializeMap on page load', (tester) async {
      when(() => mockMapBloc.state).thenReturn(const MapInitial());

      await tester.pumpWidget(makeTestableWidget(const MapPage(), mockMapBloc));

      verify(() => mockMapBloc.add(const InitializeMap())).called(1);
    });
  });
}
