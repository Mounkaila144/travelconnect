import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/questions/domain/entities/question.dart';
import 'package:travelconnect_app/features/questions/domain/usecases/create_question.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/create_question_bloc.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/create_question_event.dart';
import 'package:travelconnect_app/features/questions/presentation/bloc/create_question_state.dart';

class MockCreateQuestion extends Mock implements CreateQuestion {}

class FakeCreateQuestionParams extends Fake implements CreateQuestionParams {}

void main() {
  late CreateQuestionBloc bloc;
  late MockCreateQuestion mockCreateQuestion;

  setUpAll(() {
    registerFallbackValue(FakeCreateQuestionParams());
  });

  setUp(() {
    mockCreateQuestion = MockCreateQuestion();
    bloc = CreateQuestionBloc(
      createQuestion: mockCreateQuestion,
      initialLatitude: 35.6595,
      initialLongitude: 139.7004,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final mockQuestion = Question(
    id: 42,
    title: 'Meilleur ramen près de Shibuya ?',
    description: 'Je cherche un bon restaurant de ramen',
    latitude: 35.6595,
    longitude: 139.7004,
    locationName: 'Shibuya, Tokyo, Japan',
    city: 'Tokyo',
    answersCount: 0,
    createdAt: DateTime(2026, 1, 31),
  );

  group('CreateQuestionBloc', () {
    test('initial state emits form editing with initial coordinates', () {
      expect(
        bloc.state,
        isA<CreateQuestionFormEditing>()
            .having((s) => s.latitude, 'latitude', 35.6595)
            .having((s) => s.longitude, 'longitude', 139.7004)
            .having((s) => s.title, 'title', '')
            .having((s) => s.isValid, 'isValid', false),
      );
    });

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits valid form state when valid title entered',
      build: () => bloc,
      act: (bloc) => bloc.add(const TitleChanged('Valid question title')),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.isValid, 'isValid', true)
            .having((s) => s.title, 'title', 'Valid question title'),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits invalid form state when empty title',
      build: () => bloc,
      act: (bloc) => bloc.add(const TitleChanged('')),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.isValid, 'isValid', false)
            .having((s) => s.title, 'title', ''),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits description error when description too long',
      build: () => bloc,
      act: (bloc) =>
          bloc.add(DescriptionChanged('a' * 501)),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.descriptionError, 'error', isNotNull),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'updates location on LocationChanged',
      build: () => bloc,
      act: (bloc) => bloc.add(const LocationChanged(34.0522, 135.7681)),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.latitude, 'lat', 34.0522)
            .having((s) => s.longitude, 'lng', 135.7681),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits [Submitting, Success] when submission succeeds',
      build: () {
        when(() => mockCreateQuestion(any()))
            .thenAnswer((_) async => mockQuestion);
        return CreateQuestionBloc(
          createQuestion: mockCreateQuestion,
          initialLatitude: 35.6595,
          initialLongitude: 139.7004,
        );
      },
      act: (bloc) {
        bloc.add(const TitleChanged('Meilleur ramen près de Shibuya ?'));
        bloc.add(const SubmitQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.title, 'title', 'Meilleur ramen près de Shibuya ?')
            .having((s) => s.isValid, 'isValid', true),
        isA<CreateQuestionSubmitting>(),
        isA<CreateQuestionSuccess>()
            .having((s) => s.question.id, 'id', 42),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits title error when submitting with empty title',
      build: () => bloc,
      act: (bloc) => bloc.add(const SubmitQuestion()),
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.titleError, 'error', 'Le titre est requis'),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits error when API returns 422',
      build: () {
        when(() => mockCreateQuestion(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions'),
            response: Response(
              requestOptions: RequestOptions(path: '/questions'),
              statusCode: 422,
              data: {
                'errors': {
                  'title': ['Le titre est requis.']
                }
              },
            ),
          ),
        );
        return CreateQuestionBloc(
          createQuestion: mockCreateQuestion,
          initialLatitude: 35.6595,
          initialLongitude: 139.7004,
        );
      },
      act: (bloc) {
        bloc.add(const TitleChanged('Test Question'));
        bloc.add(const SubmitQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<CreateQuestionFormEditing>(),
        isA<CreateQuestionSubmitting>(),
        isA<CreateQuestionError>()
            .having((s) => s.message, 'message', 'Le titre est requis.'),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits error when API returns 429 rate limited',
      build: () {
        when(() => mockCreateQuestion(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions'),
            response: Response(
              requestOptions: RequestOptions(path: '/questions'),
              statusCode: 429,
              data: {'message': 'Too many requests'},
            ),
          ),
        );
        return CreateQuestionBloc(
          createQuestion: mockCreateQuestion,
          initialLatitude: 35.6595,
          initialLongitude: 139.7004,
        );
      },
      act: (bloc) {
        bloc.add(const TitleChanged('Test Question'));
        bloc.add(const SubmitQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<CreateQuestionFormEditing>(),
        isA<CreateQuestionSubmitting>(),
        isA<CreateQuestionError>().having(
          (s) => s.message,
          'message',
          contains('limite'),
        ),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'emits network error on connection failure',
      build: () {
        when(() => mockCreateQuestion(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/questions'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return CreateQuestionBloc(
          createQuestion: mockCreateQuestion,
          initialLatitude: 35.6595,
          initialLongitude: 139.7004,
        );
      },
      act: (bloc) {
        bloc.add(const TitleChanged('Test Question'));
        bloc.add(const SubmitQuestion());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<CreateQuestionFormEditing>(),
        isA<CreateQuestionSubmitting>(),
        isA<CreateQuestionError>().having(
          (s) => s.message,
          'message',
          contains('connexion'),
        ),
      ],
    );

    blocTest<CreateQuestionBloc, CreateQuestionState>(
      'resets form on ResetForm event',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const TitleChanged('Some title'));
        bloc.add(const ResetForm());
      },
      expect: () => [
        isA<CreateQuestionFormEditing>()
            .having((s) => s.title, 'title', 'Some title'),
        isA<CreateQuestionFormEditing>()
            .having((s) => s.title, 'title', '')
            .having((s) => s.description, 'description', ''),
      ],
    );
  });
}
