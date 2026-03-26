import 'dart:io';

import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? bio,
    required String countryCode,
    required String userType,
  }) async {
    return await remoteDataSource.updateProfile(
      name: name,
      bio: bio,
      countryCode: countryCode,
      userType: userType,
    );
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    return await remoteDataSource.uploadAvatar(imageFile);
  }
}
