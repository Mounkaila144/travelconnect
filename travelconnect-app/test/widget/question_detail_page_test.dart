import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' hide Answer;
import 'package:travelconnect_app/features/auth/domain/entities/user.dart';
import 'package:travelconnect_app/features/questions/domain/entities/answer.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_state.dart';
import 'package:travelconnect_app/features/questions/presentation/pages/question_detail_page.dart';
import 'package:travelconnect_app/features/questions/presentation/widgets/answers_list_widget.dart';
import 'package:travelconnect_app/features/questions/presentation/widgets/user_type_badge_widget.dart';

class MockQuestionDetailBloc
    extends Mock
    implements QuestionDetailBloc {
  @override
  Future<void> close() async {}
}

class FakeQuestionDetailEvent extends Fake implements QuestionDetailEvent {}

void main() {
  late MockQuestionDetailBloc mockBloc;

  final mockUser = const User(
    id: 1,
    email: 'john@example.com',
    name: 'John Doe',
    userType: 'traveler',
    trustScore: 3.5,
    isNew: false,
  );

  final mockAnswers = [
    Answer(
      id: 1,
      content: 'Je recommande Ichiran Ramen',
      averageRating: 4.5,
      ratingsCount: 10,
      createdAt: DateTime(2026, 1, 31, 9, 0),
      user: const User(
        id: 2,
        email: 'sato@example.com',
        name: 'Sato',
        userType: 'local_supporter',
        trustScore: 4.8,
        isNew: false,
      ),
    ),
    Answer(
      id: 2,
      content: 'Fuunji est excellent aussi',
      averageRating: 3.5,
      ratingsCount: 5,
      createdAt: DateTime(2026, 1, 31, 10, 0),
      user: const User(
        id: 3,
        email: 'tanaka@example.com',
        name: 'Tanaka',
        userType: 'traveler',
        trustScore: 2.0,
        isNew: false,
      ),
    ),
  ];

  final mockQuestion = Question(
    id: 1,
    title: 'Meilleur ramen près de Shibuya ?',
    description: 'Je cherche un bon restaurant de ramen authentique',
    latitude: 35.6595,
    longitude: 139.7004,
    locationName: 'Shibuya, Tokyo',
    answersCount: 2,
    createdAt: DateTime(2026, 1, 31, 8, 0),
    user: mockUser,
    answers: mockAnswers,
  );

  setUpAll(() {
    registerFallbackValue(FakeQuestionDetailEvent());
  });

  setUp(() {
    mockBloc = MockQuestionDetailBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<QuestionDetailBloc>.value(
        value: mockBloc,
        child: child,
      ),
    );
  }

  group('QuestionDetailPage', () {
    testWidgets('displays loading indicator when loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuestionDetailLoading());
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const QuestionDetailLoading()),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error view with retry button on error',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const QuestionDetailError("Cette question n'existe plus"),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          const QuestionDetailError("Cette question n'existe plus"),
        ),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );

      expect(find.text("Cette question n'existe plus"), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('tapping retry dispatches LoadQuestionDetail', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const QuestionDetailError('Erreur de connexion'),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const QuestionDetailError('Erreur de connexion')),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );

      await tester.tap(find.text('Réessayer'));
      verify(() => mockBloc.add(const LoadQuestionDetail(1))).called(1);
    });

    testWidgets('displays question title and description when loaded',
        (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meilleur ramen près de Shibuya ?'), findsOneWidget);
      expect(
        find.text('Je cherche un bon restaurant de ramen authentique'),
        findsOneWidget,
      );
    });

    testWidgets('displays author name and badge', (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(UserTypeBadgeWidget), findsWidgets);
    });

    testWidgets('displays answers list with correct count', (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Réponses (2)'), findsOneWidget);
      expect(find.text('Je recommande Ichiran Ramen'), findsOneWidget);
      expect(find.text('Fuunji est excellent aussi'), findsOneWidget);
    });

    testWidgets('displays Répondre FAB when loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Répondre'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows snackbar when Répondre tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Répondre'));
      await tester.pump();

      expect(
        find.text('Fonctionnalité disponible dans Epic 3'),
        findsOneWidget,
      );
    });

    testWidgets('displays location name', (tester) async {
      when(() => mockBloc.state).thenReturn(QuestionDetailLoaded(mockQuestion));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(mockQuestion)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shibuya, Tokyo'), findsOneWidget);
    });

    testWidgets('displays empty answers message when no answers',
        (tester) async {
      final questionNoAnswers = Question(
        id: 2,
        title: 'Question sans réponse',
        latitude: 35.6595,
        longitude: 139.7004,
        answersCount: 0,
        createdAt: DateTime(2026, 1, 31),
        user: mockUser,
        answers: const [],
      );

      when(() => mockBloc.state)
          .thenReturn(QuestionDetailLoaded(questionNoAnswers));
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(QuestionDetailLoaded(questionNoAnswers)),
      );

      await tester.pumpWidget(
        makeTestableWidget(const QuestionDetailPage(questionId: 2)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune réponse'), findsOneWidget);
      expect(find.text('Réponses (0)'), findsOneWidget);
    });
  });
}
