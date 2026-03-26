import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/core/services/notification_service.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notification_state.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockNotificationService = MockNotificationService();
  });

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      final bloc = NotificationBloc(
        notificationService: mockNotificationService,
      );
      expect(bloc.state, const NotificationInitial());
      bloc.close();
    });

    group('PermissionRequested', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [PermissionGranted, TokenRegistered] when permission granted and token registered',
        build: () {
          when(() => mockNotificationService.requestPermission())
              .thenAnswer((_) async => true);
          when(() => mockNotificationService.getFcmToken())
              .thenAnswer((_) async => 'test_token_123');
          when(() => mockNotificationService.registerTokenWithBackend('test_token_123'))
              .thenAnswer((_) async {});
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const PermissionRequested()),
        expect: () => [
          const PermissionGranted(),
          const TokenRegistered('test_token_123'),
        ],
        verify: (_) {
          verify(() => mockNotificationService.requestPermission()).called(1);
          verify(() => mockNotificationService.getFcmToken()).called(1);
          verify(() => mockNotificationService.registerTokenWithBackend('test_token_123'))
              .called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [PermissionDenied] when permission denied',
        build: () {
          when(() => mockNotificationService.requestPermission())
              .thenAnswer((_) async => false);
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const PermissionRequested()),
        expect: () => [const PermissionDenied()],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [PermissionGranted] only when token is null',
        build: () {
          when(() => mockNotificationService.requestPermission())
              .thenAnswer((_) async => true);
          when(() => mockNotificationService.getFcmToken())
              .thenAnswer((_) async => null);
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const PermissionRequested()),
        expect: () => [const PermissionGranted()],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationError] when exception thrown',
        build: () {
          when(() => mockNotificationService.requestPermission())
              .thenThrow(Exception('Firebase error'));
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const PermissionRequested()),
        expect: () => [isA<NotificationError>()],
      );
    });

    group('TokenReceived', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [TokenRegistered] when token registered successfully',
        build: () {
          when(() => mockNotificationService.registerTokenWithBackend('new_token'))
              .thenAnswer((_) async {});
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const TokenReceived('new_token')),
        expect: () => [const TokenRegistered('new_token')],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationError] when registration fails',
        build: () {
          when(() => mockNotificationService.registerTokenWithBackend('bad_token'))
              .thenThrow(Exception('Network error'));
          return NotificationBloc(
            notificationService: mockNotificationService,
          );
        },
        act: (bloc) => bloc.add(const TokenReceived('bad_token')),
        expect: () => [isA<NotificationError>()],
      );
    });
  });

  group('NotificationEvent', () {
    test('PermissionRequested supports value equality', () {
      expect(const PermissionRequested(), const PermissionRequested());
    });

    test('TokenReceived supports value equality', () {
      expect(const TokenReceived('abc'), const TokenReceived('abc'));
      expect(
        const TokenReceived('abc') == const TokenReceived('def'),
        false,
      );
    });

    test('NotificationReceived supports value equality', () {
      expect(
        const NotificationReceived(title: 'Test', body: 'Body'),
        const NotificationReceived(title: 'Test', body: 'Body'),
      );
    });
  });

  group('NotificationState', () {
    test('NotificationInitial supports value equality', () {
      expect(const NotificationInitial(), const NotificationInitial());
    });

    test('TokenRegistered supports value equality', () {
      expect(const TokenRegistered('abc'), const TokenRegistered('abc'));
    });

    test('NotificationError supports value equality', () {
      expect(const NotificationError('err'), const NotificationError('err'));
    });
  });
}
