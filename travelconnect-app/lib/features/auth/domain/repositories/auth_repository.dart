import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<String?> getSavedToken();
  Future<AuthResult?> restoreSession();
  Future<void> signOut();
}

class AuthResult {
  final User user;
  final String token;
  final bool isNewUser;

  const AuthResult({
    required this.user,
    required this.token,
    required this.isNewUser,
  });
}
