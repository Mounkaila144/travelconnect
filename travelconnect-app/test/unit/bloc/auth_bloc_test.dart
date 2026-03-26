import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide SignInWithApple;
import 'package:travelconnect_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:travelconnect_app/features/auth/domain/entities/user.dart';
import 'package:travelconnect_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:travelconnect_app/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:travelconnect_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:travelconnect_app/features/auth/presentation/bloc/auth_state.dart';

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignInWithApple mockSignInWithApple;
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const testUser = User(
    id: 1,
    email: 'test@gmail.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.jpg',
    userType: 'traveler',
    trustScore: 0.0,
    isNew: true,
  );

  const testAppleUser = User(
    id: 2,
    email: 'abc123@privaterelay.appleid.com',
    name: 'Apple User',
    userType: 'traveler',
    trustScore: 0.0,
    isNew: true,
  );

  const testAuthResult = AuthResult(
    user: testUser,
    token: '1|test-token',
    isNewUser: true,
  );

  const testAppleAuthResult = AuthResult(
    user: testAppleUser,
    token: '2|apple-token',
    isNewUser: true,
  );

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignInWithApple = MockSignInWithApple();
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(
      signInWithGoogle: mockSignInWithGoogle,
      signInWithApple: mockSignInWithApple,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  // Google Sign-In tests

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when SignInWithGoogleRequested succeeds',
    build: () {
      when(() => mockSignInWithGoogle()).thenAnswer(
        (_) async => testAuthResult,
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithGoogleRequested()),
    expect: () => [
      const AuthLoading(),
      const Authenticated(user: testUser, isNewUser: true),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when user cancels Google Sign-In',
    build: () {
      when(() => mockSignInWithGoogle()).thenThrow(
        const AuthCancelledException(),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithGoogleRequested()),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when Google authentication fails',
    build: () {
      when(() => mockSignInWithGoogle()).thenThrow(
        const AuthException('Test error'),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithGoogleRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthError('Test error'),
    ],
  );

  // Apple Sign-In tests

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when SignInWithAppleRequested succeeds',
    build: () {
      when(() => mockSignInWithApple()).thenAnswer(
        (_) async => testAppleAuthResult,
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithAppleRequested()),
    expect: () => [
      const AuthLoading(),
      const Authenticated(user: testAppleUser, isNewUser: true),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when user cancels Apple Sign-In',
    build: () {
      when(() => mockSignInWithApple()).thenThrow(
        const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'User cancelled',
        ),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithAppleRequested()),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when Apple credential error occurs',
    build: () {
      when(() => mockSignInWithApple()).thenThrow(
        const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.failed,
          message: 'Credential error',
        ),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithAppleRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthError("Erreur d'identification Apple. Veuillez réessayer."),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when Apple authentication throws AuthException',
    build: () {
      when(() => mockSignInWithApple()).thenThrow(
        const AuthException('Apple Sign-In is only available on iOS'),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInWithAppleRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthError('Apple Sign-In is only available on iOS'),
    ],
  );

  // Common tests

  blocTest<AuthBloc, AuthState>(
    'emits [Unauthenticated] when CheckAuthStatus finds no token',
    build: () {
      when(() => mockAuthRepository.getSavedToken()).thenAnswer(
        (_) async => null,
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const CheckAuthStatus()),
    expect: () => [
      const Unauthenticated(),
    ],
  );

  // Logout tests

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when SignOutRequested succeeds',
    build: () {
      when(() => mockAuthRepository.signOut()).thenAnswer(
        (_) async {},
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignOutRequested()),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
    verify: (_) {
      verify(() => mockAuthRepository.signOut()).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] even when signOut throws',
    build: () {
      when(() => mockAuthRepository.signOut()).thenThrow(
        Exception('Network error'),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignOutRequested()),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );
}
