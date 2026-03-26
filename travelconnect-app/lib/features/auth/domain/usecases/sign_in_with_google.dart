import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  Future<AuthResult> call() => repository.signInWithGoogle();
}
