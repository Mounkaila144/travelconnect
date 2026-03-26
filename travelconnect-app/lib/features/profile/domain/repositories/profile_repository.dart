import 'dart:io';

import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({
    required String name,
    String? bio,
    required String countryCode,
    required String userType,
  });
  Future<String> uploadAvatar(File imageFile);
}
