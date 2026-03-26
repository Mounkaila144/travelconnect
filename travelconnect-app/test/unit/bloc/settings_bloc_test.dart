import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
  });

  group('SettingsBloc', () {
    test('initial state is SettingsInitial', () {
      final bloc = SettingsBloc(settingsRepository: mockSettingsRepository);
      expect(bloc.state, const SettingsInitial());
      bloc.close();
    });

    group('LoadSettings', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsLoading, SettingsLoaded] when settings loaded successfully',
        build: () {
          when(() => mockSettingsRepository.getNotificationSettings())
              .thenAnswer((_) async => {
                    'new_answers': true,
                    'nearby_questions': true,
                  });
          return SettingsBloc(settingsRepository: mockSettingsRepository);
        },
        act: (bloc) => bloc.add(const LoadSettings()),
        expect: () => [
          const SettingsLoading(),
          const SettingsLoaded({
            'new_answers': true,
            'nearby_questions': true,
          }),
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits [SettingsLoading, SettingsError] when loading fails',
        build: () {
          when(() => mockSettingsRepository.getNotificationSettings())
              .thenThrow(Exception('Network error'));
          return SettingsBloc(settingsRepository: mockSettingsRepository);
        },
        act: (bloc) => bloc.add(const LoadSettings()),
        expect: () => [
          const SettingsLoading(),
          const SettingsError('Impossible de charger les paramètres'),
        ],
      );
    });

    group('UpdateNotificationSetting', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits optimistic update on success',
        build: () {
          when(() => mockSettingsRepository
                  .updateNotificationSettings({'new_answers': false}))
              .thenAnswer((_) async => {
                    'new_answers': false,
                    'nearby_questions': true,
                  });
          return SettingsBloc(settingsRepository: mockSettingsRepository);
        },
        seed: () => const SettingsLoaded({
          'new_answers': true,
          'nearby_questions': true,
        }),
        act: (bloc) =>
            bloc.add(const UpdateNotificationSetting('new_answers', false)),
        expect: () => [
          const SettingsLoaded({
            'new_answers': false,
            'nearby_questions': true,
          }),
        ],
        verify: (_) {
          verify(() => mockSettingsRepository
              .updateNotificationSettings({'new_answers': false})).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'reverts to original settings on failure',
        build: () {
          when(() => mockSettingsRepository
                  .updateNotificationSettings({'new_answers': false}))
              .thenThrow(Exception('Network error'));
          return SettingsBloc(settingsRepository: mockSettingsRepository);
        },
        seed: () => const SettingsLoaded({
          'new_answers': true,
          'nearby_questions': true,
        }),
        act: (bloc) =>
            bloc.add(const UpdateNotificationSetting('new_answers', false)),
        expect: () => [
          // Optimistic update
          const SettingsLoaded({
            'new_answers': false,
            'nearby_questions': true,
          }),
          // Revert
          const SettingsLoaded({
            'new_answers': true,
            'nearby_questions': true,
          }),
          // Error
          const SettingsError('Impossible de mettre à jour les paramètres'),
          // Back to loaded state
          const SettingsLoaded({
            'new_answers': true,
            'nearby_questions': true,
          }),
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'does nothing when state is not SettingsLoaded',
        build: () {
          return SettingsBloc(settingsRepository: mockSettingsRepository);
        },
        act: (bloc) =>
            bloc.add(const UpdateNotificationSetting('new_answers', false)),
        expect: () => [],
      );
    });
  });

  group('SettingsEvent', () {
    test('LoadSettings supports value equality', () {
      expect(const LoadSettings(), const LoadSettings());
    });

    test('UpdateNotificationSetting supports value equality', () {
      expect(
        const UpdateNotificationSetting('new_answers', true),
        const UpdateNotificationSetting('new_answers', true),
      );
      expect(
        const UpdateNotificationSetting('new_answers', true) ==
            const UpdateNotificationSetting('new_answers', false),
        false,
      );
    });
  });

  group('SettingsState', () {
    test('SettingsInitial supports value equality', () {
      expect(const SettingsInitial(), const SettingsInitial());
    });

    test('SettingsLoaded supports value equality', () {
      expect(
        const SettingsLoaded({'new_answers': true}),
        const SettingsLoaded({'new_answers': true}),
      );
    });

    test('SettingsError supports value equality', () {
      expect(const SettingsError('err'), const SettingsError('err'));
    });
  });
}
