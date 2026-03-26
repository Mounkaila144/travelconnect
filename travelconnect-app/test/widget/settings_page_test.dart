import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:travelconnect_app/features/settings/presentation/pages/settings_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const SettingsPage(),
      ),
      routes: {
        '/login': (_) => const Scaffold(body: Text('Login Page')),
        '/profile': (_) => const Scaffold(body: Text('Profile Page')),
      },
    );
  }

  testWidgets('displays Paramètres title', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Paramètres'), findsOneWidget);
  });

  testWidgets('displays Compte section with Mon profil', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Compte'), findsOneWidget);
    expect(find.text('Mon profil'), findsOneWidget);
  });

  testWidgets('displays Paramètres généraux section', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Paramètres généraux'), findsOneWidget);
    expect(find.text('Langue'), findsOneWidget);
  });

  testWidgets('displays À propos section', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('À propos'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
  });

  testWidgets('displays Déconnexion button in red', (tester) async {
    await tester.pumpWidget(createTestWidget());

    final logoutText = find.text('Déconnexion');
    expect(logoutText, findsOneWidget);

    final logoutIcon = find.byIcon(Icons.logout);
    expect(logoutIcon, findsOneWidget);
  });

  testWidgets('tapping Déconnexion shows confirmation dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(
        find.text('Êtes-vous sûr de vouloir vous déconnecter ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
  });

  testWidgets('cancelling dialog does not dispatch SignOutRequested',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    verifyNever(() => mockAuthBloc.add(const SignOutRequested()));
  });

  testWidgets('confirming dialog dispatches SignOutRequested', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    // Tap the Déconnexion button in the dialog (the TextButton, not the ListTile)
    await tester.tap(find.widgetWithText(TextButton, 'Déconnexion'));
    await tester.pumpAndSettle();

    verify(() => mockAuthBloc.add(const SignOutRequested())).called(1);
  });

  testWidgets('shows loading indicator during logout', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
