import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/moderation/domain/entities/report_reason.dart';
import 'package:travelconnect_app/features/moderation/domain/usecases/create_report.dart';
import 'package:travelconnect_app/features/moderation/presentation/bloc/report_bloc.dart';
import 'package:travelconnect_app/features/moderation/presentation/bloc/report_state.dart';
import 'package:travelconnect_app/features/moderation/presentation/widgets/report_reason_sheet_widget.dart';

class MockCreateReport extends Mock implements CreateReport {}

class FakeCreateReportParams extends Fake implements CreateReportParams {}

void main() {
  late MockCreateReport mockCreateReport;

  setUpAll(() {
    registerFallbackValue(FakeCreateReportParams());
  });

  setUp(() {
    mockCreateReport = MockCreateReport();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<ReportBloc>(
          create: (_) => ReportBloc(createReport: mockCreateReport),
          child: const ReportReasonSheetWidget(
            reportableType: 'Question',
            reportableId: 1,
          ),
        ),
      ),
    );
  }

  group('ReportReasonSheetWidget', () {
    testWidgets('displays header with flag icon and title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.text('Signaler ce contenu'), findsOneWidget);
    });

    testWidgets('displays all report reasons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      for (final reason in ReportReason.values) {
        expect(find.text(reason.displayName), findsOneWidget);
      }
    });

    testWidgets('displays cancel and submit buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Signaler'), findsOneWidget);
    });

    testWidgets('submit button is disabled until reason selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final submitButton = find.widgetWithText(ElevatedButton, 'Signaler');
      expect(
        tester.widget<ElevatedButton>(submitButton).onPressed,
        isNull,
      );

      // Select a reason
      await tester.tap(find.text('Spam'));
      await tester.pump();

      expect(
        tester.widget<ElevatedButton>(submitButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('displays comment text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Commentaire (optionnel)'), findsOneWidget);
      expect(
        find.text('Ajoutez des détails si nécessaire...'),
        findsOneWidget,
      );
    });

    testWidgets('can enter comment text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextField), 'Test comment');
      await tester.pump();

      expect(find.text('Test comment'), findsOneWidget);
    });

    testWidgets('close button is visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('reason label text is displayed', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Raison du signalement :'), findsOneWidget);
    });

    testWidgets('can select different reasons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Select "Contenu offensant"
      await tester.tap(find.text('Contenu offensant'));
      await tester.pump();

      // Submit button should now be enabled
      final submitButton = find.widgetWithText(ElevatedButton, 'Signaler');
      expect(
        tester.widget<ElevatedButton>(submitButton).onPressed,
        isNotNull,
      );

      // Change to "Information fausse"
      await tester.tap(find.text('Information fausse'));
      await tester.pump();

      // Submit button should still be enabled
      expect(
        tester.widget<ElevatedButton>(submitButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('submits report when button pressed', (tester) async {
      when(() => mockCreateReport(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      // Select a reason
      await tester.tap(find.text('Spam'));
      await tester.pump();

      // Tap submit
      await tester.tap(find.text('Signaler'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading state during submission', (tester) async {
      when(() => mockCreateReport(any())).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 5)),
      );

      await tester.pumpWidget(buildTestWidget());

      // Select reason and submit
      await tester.tap(find.text('Spam'));
      await tester.pump();
      await tester.tap(find.text('Signaler'));
      await tester.pump();

      // Loading indicator visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cancel button should be disabled
      final cancelButton = find.widgetWithText(OutlinedButton, 'Annuler');
      expect(
        tester.widget<OutlinedButton>(cancelButton).onPressed,
        isNull,
      );
    });

    testWidgets('shows success snackbar after submission', (tester) async {
      when(() => mockCreateReport(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      // Select reason and submit
      await tester.tap(find.text('Spam'));
      await tester.pump();
      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Signalement envoyé. Merci de contribuer à la modération.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      when(() => mockCreateReport(any())).thenThrow(Exception('fail'));

      await tester.pumpWidget(buildTestWidget());

      // Select reason and submit
      await tester.tap(find.text('Spam'));
      await tester.pump();
      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(find.text('Une erreur est survenue'), findsOneWidget);
    });
  });
}
