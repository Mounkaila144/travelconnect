import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/notifications/domain/entities/app_notification.dart';
import 'package:travelconnect_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notifications_center_bloc.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notifications_center_event.dart';
import 'package:travelconnect_app/features/notifications/presentation/bloc/notifications_center_state.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepository;
  late NotificationsCenterBloc bloc;

  final mockNotifications = [
    AppNotification(
      id: 'uuid-1',
      type: 'new_answer',
      title: 'Nouvelle réponse',
      body: 'Tanaka a répondu à votre question',
      data: const {'question_id': 1, 'answer_id': 5},
      readAt: null,
      createdAt: DateTime(2026, 1, 31, 10, 0),
      timeAgo: 'il y a 2h',
    ),
    AppNotification(
      id: 'uuid-2',
      type: 'nearby_question',
      title: 'Nouvelle question près de Shibuya',
      body: 'Best sushi restaurant?',
      data: const {'question_id': 8},
      readAt: DateTime(2026, 1, 31, 11, 0),
      createdAt: DateTime(2026, 1, 31, 9, 30),
      timeAgo: 'il y a 3h',
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationsRepository();
    bloc = NotificationsCenterBloc(notificationsRepository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationsCenterBloc', () {
    test('initial state is NotificationsCenterInitial', () {
      expect(bloc.state, isA<NotificationsCenterInitial>());
    });

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'emits [Loading, Loaded] when LoadNotifications succeeds',
      build: () {
        when(() => mockRepository.getNotifications(page: 1)).thenAnswer(
          (_) async => NotificationsResult(
            notifications: mockNotifications,
            hasMorePages: false,
            currentPage: 1,
            total: 2,
            unreadCount: 1,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect: () => [
        isA<NotificationsCenterLoading>(),
        isA<NotificationsCenterLoaded>()
            .having((s) => s.notifications.length, 'count', 2)
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'emits [Loading, Error] when LoadNotifications fails',
      build: () {
        when(() => mockRepository.getNotifications(page: 1))
            .thenThrow(Exception());
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect: () => [
        isA<NotificationsCenterLoading>(),
        isA<NotificationsCenterError>(),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'MarkAsRead updates notification and decrements unread count',
      build: () {
        when(() => mockRepository.markAsRead('uuid-1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => NotificationsCenterLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(MarkAsRead(mockNotifications[0])),
      expect: () => [
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 0)
            .having(
              (s) => s.notifications[0].readAt != null,
              'marked read',
              true,
            ),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'MarkAsRead does not decrement for already read notification',
      build: () {
        when(() => mockRepository.markAsRead('uuid-2'))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => NotificationsCenterLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(MarkAsRead(mockNotifications[1])),
      expect: () => [
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'MarkAllAsRead sets all notifications to read and unreadCount to 0',
      build: () {
        when(() => mockRepository.markAllAsRead())
            .thenAnswer((_) async => 1);
        return bloc;
      },
      seed: () => NotificationsCenterLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(const MarkAllAsRead()),
      expect: () => [
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 0)
            .having(
              (s) => s.notifications.every((n) => n.readAt != null),
              'all read',
              true,
            ),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'MarkAsRead reverts on failure',
      build: () {
        when(() => mockRepository.markAsRead('uuid-1'))
            .thenThrow(Exception());
        return bloc;
      },
      seed: () => NotificationsCenterLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(MarkAsRead(mockNotifications[0])),
      expect: () => [
        // Optimistic update
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 0),
        // Revert
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'UpdateUnreadCount updates the unread count',
      build: () => bloc,
      seed: () => const NotificationsCenterLoaded(
        notifications: [],
        unreadCount: 0,
      ),
      act: (bloc) => bloc.add(const UpdateUnreadCount(5)),
      expect: () => [
        isA<NotificationsCenterLoaded>()
            .having((s) => s.unreadCount, 'unreadCount', 5),
      ],
    );

    blocTest<NotificationsCenterBloc, NotificationsCenterState>(
      'RefreshNotifications calls getNotifications with page 1',
      build: () {
        when(() => mockRepository.getNotifications(page: 1)).thenAnswer(
          (_) async => NotificationsResult(
            notifications: mockNotifications,
            hasMorePages: false,
            currentPage: 1,
            total: 2,
            unreadCount: 1,
          ),
        );
        return bloc;
      },
      seed: () => NotificationsCenterLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(const RefreshNotifications()),
      verify: (_) {
        verify(() => mockRepository.getNotifications(page: 1)).called(1);
      },
    );
  });
}
