import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/domain/repositories/questions_repository.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/questions_feed_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/questions_feed_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/questions_feed_state.dart';

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  late MockQuestionsRepository mockRepository;
  late QuestionsFeedBloc bloc;

  final mockQuestions = [
    Question(
      id: 1,
      title: 'Best sushi in Tokyo?',
      latitude: 35.68,
      longitude: 139.65,
      locationName: 'Shibuya, Tokyo',
      city: 'Tokyo',
      answersCount: 3,
      createdAt: DateTime(2026, 1, 30),
    ),
    Question(
      id: 2,
      title: 'Bons restaurants à Kyoto?',
      latitude: 35.01,
      longitude: 135.76,
      locationName: 'Kyoto',
      city: 'Kyoto',
      answersCount: 0,
      createdAt: DateTime(2026, 1, 29),
    ),
  ];

  setUp(() {
    mockRepository = MockQuestionsRepository();
    bloc = QuestionsFeedBloc(questionsRepository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('QuestionsFeedBloc', () {
    test('initial state is FeedInitial', () {
      expect(bloc.state, isA<FeedInitial>());
    });

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'emits [Loading, Loaded] when LoadQuestions succeeds',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: any(named: 'page'),
            )).thenAnswer((_) async => QuestionsResult(
              questions: mockQuestions,
              hasMorePages: false,
              currentPage: 1,
              total: 2,
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestions()),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>()
            .having((s) => s.questions.length, 'questions count', 2)
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.sort, 'sort', 'recent'),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'emits [Loading, Error] when LoadQuestions fails',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: any(named: 'page'),
            )).thenThrow(Exception());
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestions()),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedError>(),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'ChangeSortOrder reloads questions with new sort',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: any(named: 'page'),
            )).thenAnswer((_) async => QuestionsResult(
              questions: mockQuestions.reversed.toList(),
              hasMorePages: false,
              currentPage: 1,
              total: 2,
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const ChangeSortOrder('popular')),
      expect: () => [
        isA<FeedLoading>().having((s) => s.sort, 'sort', 'popular'),
        isA<FeedLoaded>().having((s) => s.sort, 'sort', 'popular'),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'FilterByCity reloads questions with city filter',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: any(named: 'page'),
            )).thenAnswer((_) async => QuestionsResult(
              questions: [mockQuestions[0]],
              hasMorePages: false,
              currentPage: 1,
              total: 1,
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const FilterByCity('Tokyo')),
      expect: () => [
        isA<FeedLoading>().having((s) => s.city, 'city', 'Tokyo'),
        isA<FeedLoaded>()
            .having((s) => s.city, 'city', 'Tokyo')
            .having((s) => s.questions.length, 'count', 1),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'LoadMoreQuestions appends questions to existing list',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: 2,
            )).thenAnswer((_) async => QuestionsResult(
              questions: [mockQuestions[1]],
              hasMorePages: false,
              currentPage: 2,
              total: 3,
            ));
        return bloc;
      },
      seed: () => FeedLoaded(
        questions: [mockQuestions[0]],
        hasMore: true,
        currentPage: 1,
        sort: 'recent',
      ),
      act: (bloc) => bloc.add(const LoadMoreQuestions()),
      expect: () => [
        isA<FeedLoaded>()
            .having((s) => s.questions.length, 'count', 2)
            .having((s) => s.currentPage, 'page', 2),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'LoadMoreQuestions does nothing when no more pages',
      build: () => bloc,
      seed: () => FeedLoaded(
        questions: mockQuestions,
        hasMore: false,
        currentPage: 1,
        sort: 'recent',
      ),
      act: (bloc) => bloc.add(const LoadMoreQuestions()),
      expect: () => [],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'LoadPopularCities updates cities in loaded state',
      build: () {
        when(() => mockRepository.getPopularCities()).thenAnswer(
          (_) async => [
            {'city': 'Tokyo', 'questions_count': 5},
            {'city': 'Kyoto', 'questions_count': 3},
          ],
        );
        return bloc;
      },
      seed: () => FeedLoaded(
        questions: mockQuestions,
        hasMore: false,
        currentPage: 1,
        sort: 'recent',
      ),
      act: (bloc) => bloc.add(const LoadPopularCities()),
      expect: () => [
        isA<FeedLoaded>()
            .having((s) => s.popularCities.length, 'cities count', 2),
      ],
    );

    blocTest<QuestionsFeedBloc, QuestionsFeedState>(
      'RefreshQuestions calls getQuestionsFeed with page 1',
      build: () {
        when(() => mockRepository.getQuestionsFeed(
              sort: any(named: 'sort'),
              city: any(named: 'city'),
              page: 1,
            )).thenAnswer((_) async => QuestionsResult(
              questions: mockQuestions,
              hasMorePages: false,
              currentPage: 1,
              total: 2,
            ));
        return bloc;
      },
      seed: () => FeedLoaded(
        questions: mockQuestions,
        hasMore: false,
        currentPage: 1,
        sort: 'recent',
      ),
      act: (bloc) => bloc.add(const RefreshQuestions()),
      verify: (_) {
        verify(() => mockRepository.getQuestionsFeed(
              sort: 'recent',
              city: null,
              page: 1,
            )).called(1);
      },
    );
  });
}
