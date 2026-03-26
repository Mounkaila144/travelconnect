import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' hide Answer;
import 'package:travelconnect_app/features/auth/domain/entities/user.dart';
import 'package:travelconnect_app/features/questions/domain/entities/answer.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/create_answer.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/get_question_detail.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/rate_answer.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/question_detail_state.dart';

class MockGetQuestionDetail extends Mock implements GetQuestionDetail {}

class MockCreateAnswer extends Mock implements CreateAnswer {}

class MockRateAnswer extends Mock implements RateAnswer {}

class FakeCreateAnswerParams extends Fake implements CreateAnswerParams {}

class FakeRateAnswerParams extends Fake implements RateAnswerParams {}

void main() {
  late QuestionDetailBloc bloc;
  late MockGetQuestionDetail mockGetQuestionDetail;
  late MockCreateAnswer mockCreateAnswer;
  late MockRateAnswer mockRateAnswer;

  final mockUser = const User(
    id: 1,
    email: 'john@example.com',
    name: 'John Doe',
    userType: 'traveler',
    trustScore: 3.5,
    isNew: false,
  );

  final mockAnswer = Answer(
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
    userRating: 5,
  );

  final mockQuestion = Question(
    id: 1,
    title: 'Meilleur ramen près de Shibuya ?',
    description: 'Je cherche un bon restaurant de ramen authentique',
    latitude: 35.6595,
    longitude: 139.7004,
    locationName: 'Shibuya, Tokyo',
    answersCount: 1,
    createdAt: DateTime(2026, 1, 31, 8, 0),
    user: mockUser,
    answers: [mockAnswer],
  );

  final newAnswer = Answer(
    id: 2,
    content: 'Essayez Fuunji près de Shinjuku !',
    ratingsCount: 0,
    createdAt: DateTime(2026, 2, 1, 10, 0),
    user: mockUser,
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateAnswerParams());
    registerFallbackValue(FakeRateAnswerParams());
  });

  setUp(() {
    mockGetQuestionDetail = MockGetQuestionDetail();
    mockCreateAnswer = MockCreateAnswer();
    mockRateAnswer = MockRateAnswer();
    bloc = QuestionDetailBloc(
      getQuestionDetail: mockGetQuestionDetail,
      createAnswer: mockCreateAnswer,
      rateAnswer: mockRateAnswer,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('QuestionDetailBloc', () {
    test('initial state is QuestionDetailInitial', () {
      expect(bloc.state, const QuestionDetailInitial());
    });

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'emits [Loading, Loaded] when LoadQuestionDetail succeeds',
      build: () {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestionDetail(1)),
      expect: () => [
        const QuestionDetailLoading(),
        QuestionDetailLoaded(mockQuestion),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'emits [Loading, Error] with 404 message when question not found',
      build: () {
        when(() => mockGetQuestionDetail(999)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/questions/999'),
              statusCode: 404,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestionDetail(999)),
      expect: () => [
        const QuestionDetailLoading(),
        const QuestionDetailError("Cette question n'existe plus"),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'emits [Loading, Error] with connection message on network error',
      build: () {
        when(() => mockGetQuestionDetail(1)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions/1'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestionDetail(1)),
      expect: () => [
        const QuestionDetailLoading(),
        const QuestionDetailError('Erreur de connexion'),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'RefreshQuestion emits updated Loaded state on success',
      build: () {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        return bloc;
      },
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) {
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const RefreshQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const QuestionDetailLoading(),
        QuestionDetailLoaded(mockQuestion),
        QuestionDetailLoaded(mockQuestion),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'RefreshQuestion keeps current state on failure',
      build: () {
        var callCount = 0;
        when(() => mockGetQuestionDetail(1)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return mockQuestion;
          throw DioException(
            requestOptions: RequestOptions(path: '/questions/1'),
            type: DioExceptionType.connectionTimeout,
          );
        });
        return bloc;
      },
      act: (bloc) {
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const RefreshQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const QuestionDetailLoading(),
        QuestionDetailLoaded(mockQuestion),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'loaded question contains answers with user ratings',
      build: () {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadQuestionDetail(1)),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        expect(state.question.answers.length, 1);
        expect(state.question.answers.first.userRating, 5);
        expect(state.question.answers.first.averageRating, 4.5);
        expect(state.question.user?.name, 'John Doe');
      },
    );
  });

  group('QuestionDetailBloc - Answer Creation', () {
    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'ShowAnswerInput sets isAnswerInputVisible to true',
      build: () => bloc,
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) => bloc.add(const ShowAnswerInput()),
      expect: () => [
        QuestionDetailLoaded(mockQuestion, isAnswerInputVisible: true),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'HideAnswerInput sets isAnswerInputVisible to false',
      build: () => bloc,
      seed: () =>
          QuestionDetailLoaded(mockQuestion, isAnswerInputVisible: true),
      act: (bloc) => bloc.add(const HideAnswerInput()),
      expect: () => [
        QuestionDetailLoaded(mockQuestion, isAnswerInputVisible: false),
      ],
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'SubmitAnswer emits submitting then loaded with new answer',
      build: () {
        when(() => mockCreateAnswer(any())).thenAnswer(
          (_) async => newAnswer,
        );
        return bloc;
      },
      seed: () {
        // Need to set _questionId by loading first
        return QuestionDetailLoaded(mockQuestion);
      },
      act: (bloc) {
        // Set the internal _questionId
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const SubmitAnswer('Essayez Fuunji près de Shinjuku !'));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        expect(state.question.answers.length, 2);
        expect(state.question.answers.first.content,
            'Essayez Fuunji près de Shinjuku !');
        expect(state.question.answersCount, 2);
        expect(state.isAnswerInputVisible, false);
        expect(state.isSubmittingAnswer, false);
      },
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'SubmitAnswer emits error state on DioException',
      build: () {
        when(() => mockCreateAnswer(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions/1/answers'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const SubmitAnswer('Test answer'));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        expect(state.answerError, isNotNull);
        expect(state.isSubmittingAnswer, false);
      },
    );
  });

  group('QuestionDetailBloc - Rating', () {
    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'RateAnswerEvent updates answer with new rating on success',
      build: () {
        when(() => mockRateAnswer(any())).thenAnswer(
          (_) async => const RatingResult(
            averageRating: 4.5,
            ratingsCount: 11,
          ),
        );
        return bloc;
      },
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const RateAnswerEvent(answerId: 1, score: 5));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        final ratedAnswer =
            state.question.answers.firstWhere((a) => a.id == 1);
        expect(ratedAnswer.averageRating, 4.5);
        expect(ratedAnswer.ratingsCount, 11);
        expect(ratedAnswer.userRating, 5);
        expect(state.ratingSuccess, 'Note enregistrée');
      },
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'RateAnswerEvent emits error on self-rating (403)',
      build: () {
        when(() => mockRateAnswer(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/answers/1/rate'),
            response: Response(
              requestOptions: RequestOptions(path: '/answers/1/rate'),
              statusCode: 403,
            ),
          ),
        );
        return bloc;
      },
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const RateAnswerEvent(answerId: 1, score: 5));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        expect(state.ratingError, isNotNull);
        expect(state.ratingError,
            'Vous ne pouvez pas noter votre propre réponse');
      },
    );

    blocTest<QuestionDetailBloc, QuestionDetailState>(
      'RateAnswerEvent emits error on network failure',
      build: () {
        when(() => mockRateAnswer(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/answers/1/rate'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      seed: () => QuestionDetailLoaded(mockQuestion),
      act: (bloc) {
        when(() => mockGetQuestionDetail(1))
            .thenAnswer((_) async => mockQuestion);
        bloc.add(const LoadQuestionDetail(1));
        bloc.add(const RateAnswerEvent(answerId: 1, score: 5));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as QuestionDetailLoaded;
        expect(state.ratingError, 'Erreur de connexion. Réessayez.');
      },
    );
  });
}
