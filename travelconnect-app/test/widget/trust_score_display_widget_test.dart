import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect_app/core/utils/trust_score_colors.dart';
import 'package:travelconnect_app/core/widgets/trust_score_display_widget.dart';

void main() {
  group('TrustScoreDisplayWidget', () {
    testWidgets('shows "Nouveau" badge for new users', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 0.0,
              isNew: true,
              showExplanation: false,
            ),
          ),
        ),
      );

      expect(find.text('Nouveau'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('shows score with 1 decimal for established users',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 4.2,
              isNew: false,
              showExplanation: false,
            ),
          ),
        ),
      );

      expect(find.text('4.2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('uses correct color for low score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 1.5,
              isNew: false,
              showExplanation: false,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.red.shade600);
    });

    testWidgets('uses correct color for high score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 4.7,
              isNew: false,
              showExplanation: false,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.green.shade700);
    });

    testWidgets('uses orange color for medium score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 2.5,
              isNew: false,
              showExplanation: false,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.orange.shade600);
    });

    testWidgets('shows explanation dialog on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 3.5,
              isNew: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TrustScoreDisplayWidget));
      await tester.pumpAndSettle();

      expect(find.text('Score de Confiance'), findsOneWidget);
      expect(find.text('Comment est-il calculé ?'), findsOneWidget);
    });

    testWidgets('does not show dialog when showExplanation is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 3.5,
              isNew: false,
              showExplanation: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TrustScoreDisplayWidget));
      await tester.pumpAndSettle();

      expect(find.text('Score de Confiance'), findsNothing);
    });

    testWidgets('new badge shows sparkle icon and blue styling',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 0.0,
              isNew: true,
              showExplanation: false,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.auto_awesome));
      expect(icon.color, Colors.blue.shade700);
    });

    testWidgets('explanation dialog shows new user section for new users',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustScoreDisplayWidget(
              score: 0.0,
              isNew: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TrustScoreDisplayWidget));
      await tester.pumpAndSettle();

      expect(find.text('Vous êtes nouveau !'), findsOneWidget);
    });
  });

  group('TrustScoreColors', () {
    test('returns red for score < 2.0', () {
      expect(
        TrustScoreColors.getColorForScore(1.5),
        Colors.red.shade600,
      );
    });

    test('returns orange for score 2.0-2.9', () {
      expect(
        TrustScoreColors.getColorForScore(2.5),
        Colors.orange.shade600,
      );
    });

    test('returns yellow for score 3.0-3.9', () {
      expect(
        TrustScoreColors.getColorForScore(3.5),
        Colors.yellow.shade700,
      );
    });

    test('returns light green for score 4.0-4.4', () {
      expect(
        TrustScoreColors.getColorForScore(4.2),
        Colors.lightGreen.shade600,
      );
    });

    test('returns dark green for score >= 4.5', () {
      expect(
        TrustScoreColors.getColorForScore(4.8),
        Colors.green.shade700,
      );
    });

    test('getScoreLabel returns correct labels', () {
      expect(TrustScoreColors.getScoreLabel(1.0), 'Débutant');
      expect(TrustScoreColors.getScoreLabel(2.5), 'En progression');
      expect(TrustScoreColors.getScoreLabel(3.5), 'Fiable');
      expect(TrustScoreColors.getScoreLabel(4.2), 'Excellent');
      expect(TrustScoreColors.getScoreLabel(4.8), 'Expert');
    });
  });
}
