import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/moderation/domain/usecases/create_report.dart';
import 'package:travelconnect_app/features/moderation/presentation/bloc/report_bloc.dart';
import 'package:travelconnect_app/features/moderation/presentation/bloc/report_event.dart';
import 'package:travelconnect_app/features/moderation/presentation/bloc/report_state.dart';
import 'package:travelconnect_app/features/moderation/domain/entities/report_reason.dart';

class MockCreateReport extends Mock implements CreateReport {}

class FakeCreateReportParams extends Fake implements CreateReportParams {}

void main() {
  late ReportBloc bloc;
  late MockCreateReport mockCreateReport;

  setUpAll(() {
    registerFallbackValue(FakeCreateReportParams());
  });

  setUp(() {
    mockCreateReport = MockCreateReport();
    bloc = ReportBloc(createReport: mockCreateReport);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is ReportInitial', () {
    expect(bloc.state, isA<ReportInitial>());
  });

  group('SubmitReport', () {
    const tEvent = SubmitReport(
      reportableType: 'Question',
      reportableId: 1,
      reason: 'spam',
      comment: 'This is spam',
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportSubmitted] on success',
      build: () {
        when(() => mockCreateReport(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportSubmitted>(),
      ],
      verify: (_) {
        verify(() => mockCreateReport(any())).called(1);
      },
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportSubmitted] without comment',
      build: () {
        when(() => mockCreateReport(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const SubmitReport(
        reportableType: 'Answer',
        reportableId: 2,
        reason: 'offensive',
      )),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportSubmitted>(),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportError] on duplicate report (422)',
      build: () {
        when(() => mockCreateReport(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/reports'),
            response: Response(
              requestOptions: RequestOptions(path: '/reports'),
              statusCode: 422,
              data: {
                'error': {
                  'code': 'DUPLICATE_REPORT',
                  'message': 'Vous avez déjà signalé ce contenu',
                },
              },
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportError>().having(
          (e) => e.message,
          'message',
          'Vous avez déjà signalé ce contenu',
        ),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportError] on 422 without error body',
      build: () {
        when(() => mockCreateReport(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/reports'),
            response: Response(
              requestOptions: RequestOptions(path: '/reports'),
              statusCode: 422,
              data: null,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportError>().having(
          (e) => e.message,
          'message',
          'Vous avez déjà signalé ce contenu',
        ),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportError] on connection error',
      build: () {
        when(() => mockCreateReport(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/reports'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportError>().having(
          (e) => e.message,
          'message',
          'Erreur de connexion. Réessayez.',
        ),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportSubmitting, ReportError] on unexpected error',
      build: () {
        when(() => mockCreateReport(any())).thenThrow(Exception('unexpected'));
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<ReportSubmitting>(),
        isA<ReportError>().having(
          (e) => e.message,
          'message',
          'Une erreur est survenue',
        ),
      ],
    );
  });

  group('ReportEvent equality', () {
    test('SubmitReport props are correct', () {
      const event = SubmitReport(
        reportableType: 'Question',
        reportableId: 1,
        reason: 'spam',
        comment: 'Test',
      );
      expect(event.props, ['Question', 1, 'spam', 'Test']);
    });

    test('SubmitReport without comment', () {
      const event = SubmitReport(
        reportableType: 'Answer',
        reportableId: 2,
        reason: 'offensive',
      );
      expect(event.props, ['Answer', 2, 'offensive', null]);
    });
  });

  group('ReportState equality', () {
    test('ReportError with same message are equal', () {
      expect(
        const ReportError('test'),
        equals(const ReportError('test')),
      );
    });

    test('ReportError with different messages are not equal', () {
      expect(
        const ReportError('a'),
        isNot(equals(const ReportError('b'))),
      );
    });
  });

  group('ReportReason', () {
    test('displayName returns correct French labels', () {
      expect(
        ReportReason.spam.displayName,
        'Spam',
      );
      expect(
        ReportReason.offensive.displayName,
        'Contenu offensant',
      );
      expect(
        ReportReason.falseInfo.displayName,
        'Information fausse',
      );
      expect(
        ReportReason.other.displayName,
        'Autre',
      );
    });

    test('apiValue returns correct API values', () {
      expect(ReportReason.spam.apiValue, 'spam');
      expect(ReportReason.offensive.apiValue, 'offensive');
      expect(ReportReason.falseInfo.apiValue, 'false_info');
      expect(ReportReason.other.apiValue, 'other');
    });

    test('enum has 4 values', () {
      expect(ReportReason.values.length, 4);
    });
  });
}
