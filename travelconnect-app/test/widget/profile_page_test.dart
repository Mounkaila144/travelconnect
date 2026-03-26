import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/auth/domain/entities/user.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:travelconnect_app/features/profile/presentation/pages/profile_page.dart';

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
    when(() => mockProfileBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockProfileBloc.close()).thenAnswer((_) async {});
  });

  Widget buildWidget(ProfileState state) {
    when(() => mockProfileBloc.state).thenReturn(state);
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: mockProfileBloc,
        child: const ProfilePage(),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('displays trust score as "Nouveau" for 0.0', (tester) async {
      const user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        userType: 'traveler',
        trustScore: 0.0,
        isNew: false,
        countryCode: 'JP',
      );

      await tester.pumpWidget(buildWidget(
        const ProfileLoaded(profile: user),
      ));

      expect(find.text('Nouveau'), findsOneWidget);
    });

    testWidgets('displays numeric trust score for > 0.0', (tester) async {
      const user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        userType: 'traveler',
        trustScore: 4.2,
        isNew: false,
        countryCode: 'JP',
      );

      await tester.pumpWidget(buildWidget(
        const ProfileLoaded(profile: user),
      ));

      expect(find.text('4.2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Nouveau'), findsNothing);
    });

    testWidgets('displays user type badge for traveler', (tester) async {
      const user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        userType: 'traveler',
        trustScore: 0.0,
        isNew: false,
        countryCode: 'JP',
      );

      await tester.pumpWidget(buildWidget(
        const ProfileLoaded(profile: user),
      ));

      expect(find.text('Voyageur'), findsOneWidget);
      expect(find.byIcon(Icons.luggage), findsOneWidget);
    });

    testWidgets('displays user type badge for local supporter', (tester) async {
      const user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Local Helper',
        userType: 'local_supporter',
        trustScore: 3.5,
        isNew: false,
        countryCode: 'FR',
      );

      await tester.pumpWidget(buildWidget(
        const ProfileLoaded(profile: user),
      ));

      expect(find.text('Local Supporter'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays all user information correctly', (tester) async {
      const user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Tanaka Yuki',
        bio: 'Voyageur passionné',
        userType: 'traveler',
        trustScore: 4.2,
        isNew: false,
        countryCode: 'JP',
        questionsCount: 5,
        answersCount: 12,
      );

      await tester.pumpWidget(buildWidget(
        const ProfileLoaded(profile: user),
      ));

      expect(find.text('Tanaka Yuki'), findsOneWidget);
      expect(find.text('Voyageur passionné'), findsOneWidget);
      expect(find.text('JP'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Modifier le profil'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildWidget(const ProfileLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button on error',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        const ProfileError(message: 'Erreur de connexion'),
      ));

      expect(find.text('Erreur de connexion'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });
}
