import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelconnect_app/features/settings/presentation/widgets/logout_confirmation_dialog.dart';

void main() {
  group('Logout Confirmation Dialog', () {
    testWidgets('displays correct title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showLogoutConfirmationDialog(context),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsOneWidget);
      expect(
          find.text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('returns false when Annuler is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showLogoutConfirmationDialog(context);
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('returns true when Déconnexion button is tapped',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showLogoutConfirmationDialog(context);
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Déconnexion'));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });
}
