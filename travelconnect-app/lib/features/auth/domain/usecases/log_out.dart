import '../repositories/auth_repository.dart';

class LogOut {
  final AuthRepository repository;

  const LogOut(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}
