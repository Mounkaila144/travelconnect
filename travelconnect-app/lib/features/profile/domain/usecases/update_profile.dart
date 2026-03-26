import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<User> call({
    required String name,
    String? bio,
    required String countryCode,
    required String userType,
  }) =>
      repository.updateProfile(
        name: name,
        bio: bio,
        countryCode: countryCode,
        userType: userType,
      );
}
