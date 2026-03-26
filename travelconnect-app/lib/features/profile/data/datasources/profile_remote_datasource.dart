import 'dart:io';

import 'package:dio/dio.dart';

import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    required String name,
    String? bio,
    required String countryCode,
    required String userType,
  });
  Future<String> uploadAvatar(File imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await dio.get('/user/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String name,
    String? bio,
    required String countryCode,
    required String userType,
  }) async {
    final response = await dio.put('/user/profile', data: {
      'name': name,
      'bio': bio,
      'country_code': countryCode,
      'user_type': userType,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar.jpg',
      ),
    });

    final response = await dio.post('/user/avatar', data: formData);
    return response.data['avatar_url'] as String;
  }
}
