import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect_app/features/questions/presentation/widgets/answer_input_widget.dart';

void main() {
  group('AnswerInputWidget', () {
    testWidgets('displays text field with character counter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('0/1000'), findsOneWidget);
    });

    testWidgets('send button is disabled when input is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      final sendButton = find.widgetWithText(ElevatedButton, 'Envoyer');
      expect(tester.widget<ElevatedButton>(sendButton).onPressed, isNull);
    });

    testWidgets('send button is enabled when input has text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test answer');
      await tester.pump();

      final sendButton = find.widgetWithText(ElevatedButton, 'Envoyer');
      expect(tester.widget<ElevatedButton>(sendButton).onPressed, isNotNull);
    });

    testWidgets('character counter updates on input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.text('5/1000'), findsOneWidget);
    });

    testWidgets('shows loading indicator when submitting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
              isSubmitting: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('cancel button calls onCancel', (tester) async {
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Annuler'));
      expect(cancelled, true);
    });

    testWidgets('submit calls onSubmit with trimmed text', (tester) async {
      String? submittedContent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (content) => submittedContent = content,
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  Test answer  ');
      await tester.pump();
      await tester.tap(find.text('Envoyer'));

      expect(submittedContent, 'Test answer');
    });

    testWidgets('text field is disabled when submitting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerInputWidget(
              onSubmit: (_) {},
              onCancel: () {},
              isSubmitting: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });
  });
}
