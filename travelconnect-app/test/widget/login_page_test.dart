import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:travelconnect_app/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

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
    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('displays "Continuer avec Google" button', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('displays TravelConnect branding', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('TravelConnect'), findsOneWidget);
    expect(find.text('Connectez-vous pour commencer'), findsOneWidget);
  });

  testWidgets('shows loading indicator during authentication', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping Google button dispatches SignInWithGoogleRequested',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pump();

    verify(() => mockAuthBloc.add(const SignInWithGoogleRequested())).called(1);
  });

  testWidgets(
    'Apple button is NOT displayed on non-iOS platforms',
    (tester) async {
      // This test runs on the host OS (not iOS), verifying AC7:
      // "Sur Android, le bouton Apple n'est pas affiché"
      if (Platform.isIOS) return; // Skip if running on iOS

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Continuer avec Apple'), findsNothing);
    },
  );

  testWidgets(
    'Apple button IS displayed on iOS',
    (tester) async {
      // This test can only pass on an actual iOS device/simulator
      if (!Platform.isIOS) return; // Skip on non-iOS

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Continuer avec Apple'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Apple button dispatches SignInWithAppleRequested on iOS',
    (tester) async {
      if (!Platform.isIOS) return; // Skip on non-iOS

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continuer avec Apple'));
      await tester.pump();

      verify(() => mockAuthBloc.add(const SignInWithAppleRequested()))
          .called(1);
    },
  );
}
