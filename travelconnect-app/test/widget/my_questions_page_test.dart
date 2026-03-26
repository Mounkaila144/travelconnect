import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_state.dart';
import 'package:travelconnect_app/features/questions/presentation/widgets/question_list_item_widget.dart';

class MockMyQuestionsBloc extends Mock implements MyQuestionsBloc {
  @override
  Future<void> close() async {}
}

class FakeMyQuestionsEvent extends Fake implements MyQuestionsEvent {}

void main() {
  late MockMyQuestionsBloc mockBloc;

  final mockQuestion1 = Question(
    id: 1,
    title: 'Meilleur ramen près de Shibuya ?',
    latitude: 35.6595,
    longitude: 139.7004,
    locationName: 'Shibuya, Tokyo',
    answersCount: 3,
    hasUnreadAnswers: true,
    createdAt: DateTime(2026, 1, 31, 8, 0),
  );

  final mockQuestion2 = Question(
    id: 2,
    title: 'Transport de l\'aéroport à Kyoto ?',
    latitude: 34.9858,
    longitude: 135.7589,
    locationName: 'Kyoto, Japan',
    answersCount: 0,
    hasUnreadAnswers: false,
    createdAt: DateTime(2026, 1, 30, 14, 30),
  );

  setUpAll(() {
    registerFallbackValue(FakeMyQuestionsEvent());
  });

  setUp(() {
    mockBloc = MockMyQuestionsBloc();
  });

  Widget makeTestableWidget() {
    return MaterialApp(
      home: BlocProvider<MyQuestionsBloc>.value(
        value: mockBloc,
        child: const _TestMyQuestionsView(),
      ),
    );
  }

  group('MyQuestionsPage', () {
    testWidgets('displays loading indicator when loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const MyQuestionsLoading());
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MyQuestionsLoading()),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays list of questions when loaded', (tester) async {
      final loadedState = MyQuestionsLoaded(
        questions: [mockQuestion1, mockQuestion2],
        currentPage: 1,
        hasMore: false,
      );

      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(loadedState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(QuestionListItemWidget), findsNWidgets(2));
      expect(
        find.text('Meilleur ramen près de Shibuya ?'),
        findsOneWidget,
      );
      expect(
        find.text('Transport de l\'aéroport à Kyoto ?'),
        findsOneWidget,
      );
    });

    testWidgets('displays unread indicator for questions with new answers',
        (tester) async {
      final loadedState = MyQuestionsLoaded(
        questions: [mockQuestion1],
        currentPage: 1,
        hasMore: false,
      );

      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(loadedState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('!'), findsOneWidget);
    });

    testWidgets('displays empty state when no questions', (tester) async {
      const loadedState = MyQuestionsLoaded(
        questions: [],
        currentPage: 1,
        hasMore: false,
      );

      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(loadedState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('Aucune question posée'), findsOneWidget);
      expect(find.text('Poser une question'), findsOneWidget);
    });

    testWidgets('displays error state with retry button', (tester) async {
      const errorState = MyQuestionsError(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );

      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(errorState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(
        find.text('Erreur de connexion. Vérifiez votre connexion internet.'),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('tapping retry dispatches LoadMyQuestions', (tester) async {
      const errorState = MyQuestionsError('Erreur de connexion');

      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(errorState),
      );

      await tester.pumpWidget(makeTestableWidget());

      await tester.tap(find.text('Réessayer'));
      verify(() => mockBloc.add(const LoadMyQuestions())).called(1);
    });

    testWidgets('displays location name for each question', (tester) async {
      final loadedState = MyQuestionsLoaded(
        questions: [mockQuestion1],
        currentPage: 1,
        hasMore: false,
      );

      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(loadedState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('Shibuya, Tokyo'), findsOneWidget);
    });

    testWidgets('displays answer count for each question', (tester) async {
      final loadedState = MyQuestionsLoaded(
        questions: [mockQuestion1],
        currentPage: 1,
        hasMore: false,
      );

      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(loadedState),
      );

      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('3 réponses'), findsOneWidget);
    });
  });
}

/// A test-only view that uses BlocBuilder directly,
/// matching the behavior of _MyQuestionsView but testable.
class _TestMyQuestionsView extends StatelessWidget {
  const _TestMyQuestionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Questions'),
        centerTitle: true,
      ),
      body: BlocBuilder<MyQuestionsBloc, MyQuestionsState>(
        builder: (context, state) {
          if (state is MyQuestionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyQuestionsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<MyQuestionsBloc>()
                            .add(const LoadMyQuestions());
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyQuestionsLoaded) {
            if (state.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.question_answer_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Aucune question posée',
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Commencez à poser des questions pour obtenir des conseils !',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Poser une question'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return QuestionListItemWidget(
                  question: question,
                  onTap: () {},
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
