import 'dart:io';

import '../repositories/profile_repository.dart';

class UploadAvatar {
  final ProfileRepository repository;

  UploadAvatar(this.repository);

  Future<String> call(File imageFile) => repository.uploadAvatar(imageFile);
}
