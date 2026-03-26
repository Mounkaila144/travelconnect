import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/notification_zone_bloc.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/notification_zone_event.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/notification_zone_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late NotificationZoneBloc bloc;

  setUp(() {
    mockRepository = MockSettingsRepository();
    bloc = NotificationZoneBloc(settingsRepository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationZoneBloc', () {
    test('initial state is NotificationZoneInitial', () {
      expect(bloc.state, isA<NotificationZoneInitial>());
    });

    blocTest<NotificationZoneBloc, NotificationZoneState>(
      'emits [Loading, Loaded] when LoadNotificationZone succeeds',
      build: () {
        when(() => mockRepository.getNotificationZone()).thenAnswer(
          (_) async => {
            'latitude': 35.6762,
            'longitude': 139.6503,
            'radius_km': 10,
          },
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotificationZone()),
      expect: () => [
        isA<NotificationZoneLoading>(),
        isA<NotificationZoneLoaded>()
            .having((s) => s.latitude, 'latitude', 35.6762)
            .having((s) => s.longitude, 'longitude', 139.6503)
            .having((s) => s.radiusKm, 'radiusKm', 10),
      ],
    );

    blocTest<NotificationZoneBloc, NotificationZoneState>(
      'emits [Loading, Loaded] with nulls when zone not configured',
      build: () {
        when(() => mockRepository.getNotificationZone()).thenAnswer(
          (_) async => {
            'latitude': null,
            'longitude': null,
            'radius_km': null,
          },
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotificationZone()),
      expect: () => [
        isA<NotificationZoneLoading>(),
        isA<NotificationZoneLoaded>()
            .having((s) => s.latitude, 'latitude', null)
            .having((s) => s.longitude, 'longitude', null),
      ],
    );

    blocTest<NotificationZoneBloc, NotificationZoneState>(
      'emits [Loading, Error] when LoadNotificationZone fails',
      build: () {
        when(() => mockRepository.getNotificationZone())
            .thenThrow(Exception());
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotificationZone()),
      expect: () => [
        isA<NotificationZoneLoading>(),
        isA<NotificationZoneError>(),
      ],
    );

    blocTest<NotificationZoneBloc, NotificationZoneState>(
      'emits [Saving, Saved] when SaveNotificationZone succeeds',
      build: () {
        when(() => mockRepository.setNotificationZone(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const SaveNotificationZone(
        latitude: 35.6762,
        longitude: 139.6503,
        radiusKm: 10,
      )),
      expect: () => [
        isA<NotificationZoneSaving>(),
        isA<NotificationZoneSaved>(),
      ],
    );

    blocTest<NotificationZoneBloc, NotificationZoneState>(
      'emits [Saving, Error] when SaveNotificationZone fails',
      build: () {
        when(() => mockRepository.setNotificationZone(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
            )).thenThrow(Exception());
        return bloc;
      },
      act: (bloc) => bloc.add(const SaveNotificationZone(
        latitude: 35.6762,
        longitude: 139.6503,
        radiusKm: 10,
      )),
      expect: () => [
        isA<NotificationZoneSaving>(),
        isA<NotificationZoneError>(),
      ],
    );
  });
}
