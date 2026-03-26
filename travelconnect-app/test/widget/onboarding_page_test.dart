import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:travelconnect_app/features/profile/presentation/pages/onboarding_page.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}

class FakeProfileEvent extends Fake implements ProfileEvent {}

class FakeProfileState extends Fake implements ProfileState {}

void main() {
  late MockProfileBloc mockProfileBloc;

  setUpAll(() {
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeProfileState());
  });

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
    when(() => mockProfileBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockProfileBloc.close()).thenAnswer((_) async {});
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: mockProfileBloc,
        child: const OnboardingPage(),
      ),
    );
  }

  group('OnboardingPage', () {
    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Complétez votre profil'), findsOneWidget);
      expect(find.text('Bienvenue sur TravelConnect !'), findsOneWidget);
      expect(find.text("Nom d'affichage *"), findsOneWidget);
      expect(find.text('Vous êtes... *'), findsOneWidget);
      expect(find.text('Voyageur'), findsOneWidget);
      expect(find.text('Local Supporter'), findsOneWidget);
      expect(find.text('Terminer'), findsOneWidget);
    });

    testWidgets('displays bio field with character limit', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Bio courte (optionnel)'), findsOneWidget);
    });

    testWidgets('name field validates minimum length', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Enter single character name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'A');

      // Tap submit
      await tester.tap(find.text('Terminer'));
      await tester.pump();

      expect(find.text('Le nom doit contenir au moins 2 caractères'),
          findsOneWidget);
    });

    testWidgets('user type selector shows two options', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Voyageur'), findsOneWidget);
      expect(find.text('Local Supporter'), findsOneWidget);
      expect(find.byIcon(Icons.luggage), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('country dropdown has default value JP', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Japon'), findsOneWidget);
    });
  });
}
