import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:travelconnect_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:travelconnect_app/features/settings/presentation/pages/notification_settings_page.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SettingsBloc>.value(
        value: mockSettingsBloc,
        child: const NotificationSettingsPage(),
      ),
    );
  }

  group('NotificationSettingsPage', () {
    testWidgets('shows loading indicator when state is SettingsLoading',
        (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows toggle switches when settings loaded', (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsLoaded({
        'new_answers': true,
        'nearby_questions': false,
      }));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Nouvelles réponses'), findsOneWidget);
      expect(find.text('Questions proches'), findsOneWidget);

      // Find SwitchListTile widgets
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.length, 2);

      final newAnswersSwitch = switches.first;
      final nearbyQuestionsSwitch = switches.last;
      expect(newAnswersSwitch.value, true);
      expect(nearbyQuestionsSwitch.value, false);
    });

    testWidgets('dispatches UpdateNotificationSetting when toggled',
        (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsLoaded({
        'new_answers': true,
        'nearby_questions': true,
      }));

      await tester.pumpWidget(buildTestWidget());

      // Tap the first switch (new_answers)
      await tester.tap(find.byType(SwitchListTile).first);

      verify(() => mockSettingsBloc
          .add(const UpdateNotificationSetting('new_answers', false))).called(1);
    });

    testWidgets('shows error state with retry button', (tester) async {
      when(() => mockSettingsBloc.state)
          .thenReturn(const SettingsError('Test error'));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('dispatches LoadSettings when retry button tapped',
        (tester) async {
      when(() => mockSettingsBloc.state)
          .thenReturn(const SettingsError('Test error'));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Réessayer'));

      verify(() => mockSettingsBloc.add(const LoadSettings())).called(1);
    });

    testWidgets('shows snackbar when SettingsError emitted', (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsLoaded({
        'new_answers': true,
        'nearby_questions': true,
      }));

      whenListen(
        mockSettingsBloc,
        Stream<SettingsState>.fromIterable([
          const SettingsError('Erreur de mise à jour'),
        ]),
        initialState: const SettingsLoaded({
          'new_answers': true,
          'nearby_questions': true,
        }),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Erreur de mise à jour'), findsOneWidget);
    });

    testWidgets('displays correct subtitle text for each setting',
        (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsLoaded({
        'new_answers': true,
        'nearby_questions': true,
      }));

      await tester.pumpWidget(buildTestWidget());

      expect(
        find.text(
            'Recevoir une notification quand quelqu\'un répond à vos questions'),
        findsOneWidget,
      );
      expect(
        find.text(
            'Recevoir une notification pour les nouvelles questions dans votre zone'),
        findsOneWidget,
      );
    });
  });
}
