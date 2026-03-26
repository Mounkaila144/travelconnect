import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/domain/repositories/questions_repository.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/get_user_questions.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/my_questions_state.dart';

class MockGetUserQuestions extends Mock implements GetUserQuestions {}

void main() {
  late MyQuestionsBloc bloc;
  late MockGetUserQuestions mockGetUserQuestions;

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

  final mockQuestion3 = Question(
    id: 3,
    title: 'Où acheter un JR Pass ?',
    latitude: 35.6812,
    longitude: 139.7671,
    locationName: 'Tokyo Station',
    answersCount: 5,
    hasUnreadAnswers: false,
    createdAt: DateTime(2026, 1, 29, 10, 0),
  );

  setUp(() {
    mockGetUserQuestions = MockGetUserQuestions();
    bloc = MyQuestionsBloc(getUserQuestions: mockGetUserQuestions);
  });

  tearDown(() {
    bloc.close();
  });

  group('MyQuestionsBloc', () {
    test('initial state is MyQuestionsInitial', () {
      expect(bloc.state, const MyQuestionsInitial());
    });

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'emits [Loading, Loaded] when LoadMyQuestions succeeds',
      build: () {
        when(() => mockGetUserQuestions(page: 1)).thenAnswer(
          (_) async => QuestionsResult(
            questions: [mockQuestion1, mockQuestion2],
            hasMorePages: false,
            currentPage: 1,
            total: 2,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMyQuestions()),
      expect: () => [
        const MyQuestionsLoading(),
        isA<MyQuestionsLoaded>()
            .having((s) => s.questions.length, 'count', 2)
            .having((s) => s.currentPage, 'page', 1)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'emits [Loading, Error] on DioException',
      build: () {
        when(() => mockGetUserQuestions(page: 1)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/user/questions'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMyQuestions()),
      expect: () => [
        const MyQuestionsLoading(),
        const MyQuestionsError(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        ),
      ],
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'loads more questions when LoadMoreMyQuestions is added',
      build: () {
        when(() => mockGetUserQuestions(page: 2)).thenAnswer(
          (_) async => QuestionsResult(
            questions: [mockQuestion3],
            hasMorePages: false,
            currentPage: 2,
            total: 3,
          ),
        );
        return bloc;
      },
      seed: () => MyQuestionsLoaded(
        questions: [mockQuestion1, mockQuestion2],
        currentPage: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreMyQuestions()),
      expect: () => [
        isA<MyQuestionsLoaded>()
            .having((s) => s.isLoadingMore, 'loading', true),
        isA<MyQuestionsLoaded>()
            .having((s) => s.questions.length, 'count', 3)
            .having((s) => s.currentPage, 'page', 2)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'does not load more when hasMore is false',
      build: () => bloc,
      seed: () => MyQuestionsLoaded(
        questions: [mockQuestion1],
        currentPage: 1,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreMyQuestions()),
      expect: () => [],
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'refresh reloads from page 1',
      build: () {
        when(() => mockGetUserQuestions(page: 1)).thenAnswer(
          (_) async => QuestionsResult(
            questions: [mockQuestion1],
            hasMorePages: false,
            currentPage: 1,
            total: 1,
          ),
        );
        return bloc;
      },
      seed: () => MyQuestionsLoaded(
        questions: [mockQuestion1, mockQuestion2],
        currentPage: 2,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const RefreshMyQuestions()),
      expect: () => [
        isA<MyQuestionsLoaded>()
            .having((s) => s.questions.length, 'count', 1)
            .having((s) => s.currentPage, 'page', 1),
      ],
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'MarkQuestionAsRead updates hasUnreadAnswers to false',
      build: () => bloc,
      seed: () => MyQuestionsLoaded(
        questions: [mockQuestion1],
        currentPage: 1,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const MarkQuestionAsRead(1)),
      verify: (bloc) {
        final state = bloc.state as MyQuestionsLoaded;
        expect(state.questions.first.hasUnreadAnswers, false);
      },
    );

    blocTest<MyQuestionsBloc, MyQuestionsState>(
      'emits Loaded with empty list when user has no questions',
      build: () {
        when(() => mockGetUserQuestions(page: 1)).thenAnswer(
          (_) async => const QuestionsResult(
            questions: [],
            hasMorePages: false,
            currentPage: 1,
            total: 0,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMyQuestions()),
      expect: () => [
        const MyQuestionsLoading(),
        isA<MyQuestionsLoaded>()
            .having((s) => s.questions, 'questions', isEmpty)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );
  });
}
