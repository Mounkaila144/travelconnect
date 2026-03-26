import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect_app/features/questions/presentation/widgets/rating_stars_input_widget.dart';

void main() {
  group('RatingStarsInputWidget', () {
    testWidgets('displays 5 star icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // 5 empty stars
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('tapping star calls onRatingChanged with correct value',
        (tester) async {
      int? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              onRatingChanged: (rating) => selectedRating = rating,
            ),
          ),
        ),
      );

      // Tap third star
      await tester.tap(find.byIcon(Icons.star_border).at(2));
      await tester.pump();

      expect(selectedRating, 3);
    });

    testWidgets('initial rating shows filled stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              initialRating: 3,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('stars are not tappable when loading', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              isLoading: true,
              onRatingChanged: (_) => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              isLoading: true,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping first star sets rating to 1', (tester) async {
      int? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              onRatingChanged: (rating) => selectedRating = rating,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      expect(selectedRating, 1);
    });

    testWidgets('tapping last star sets rating to 5', (tester) async {
      int? selectedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInputWidget(
              onRatingChanged: (rating) => selectedRating = rating,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_border).last);
      await tester.pump();

      expect(selectedRating, 5);
    });
  });
}
