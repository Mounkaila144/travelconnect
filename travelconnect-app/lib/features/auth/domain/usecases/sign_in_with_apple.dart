import '../repositories/auth_repository.dart';

class SignInWithApple {
  final AuthRepository repository;

  const SignInWithApple(this.repository);

  Future<AuthResult> call() => repository.signInWithApple();
}
