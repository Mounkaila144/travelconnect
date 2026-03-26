import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Dio dio;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.dio,
  });

  @override
  Future<AuthResult> signInWithGoogle() async {
    debugPrint('[AUTH] Getting Google ID token...');
    final idToken = await remoteDataSource.getGoogleIdToken();
    debugPrint('[AUTH] Got Google ID token, calling backend...');
    final authResponse = await remoteDataSource.authenticateWithBackend(idToken);
    debugPrint('[AUTH] Backend returned token: ${authResponse.token.substring(0, 10)}...');
    await localDataSource.saveToken(authResponse.token);
    final savedToken = await localDataSource.getToken();
    debugPrint('[AUTH] Token saved and verified: ${savedToken != null}');
    return authResponse.toAuthResult();
  }

  @override
  Future<AuthResult> signInWithApple() async {
    final appleResult = await remoteDataSource.getAppleCredentials();
    final authResponse = await remoteDataSource.authenticateAppleWithBackend(
      identityToken: appleResult.identityToken,
      authorizationCode: appleResult.authorizationCode,
      fullName: appleResult.fullName,
    );
    await localDataSource.saveToken(authResponse.token);
    return authResponse.toAuthResult();
  }

  @override
  Future<String?> getSavedToken() async {
    return localDataSource.getToken();
  }

  @override
  Future<AuthResult?> restoreSession() async {
    final token = await localDataSource.getToken();
    if (token == null) return null;

    try {
      final response = await dio.get('/user/profile');
      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data);
      return AuthResult(user: user, token: token, isNewUser: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await localDataSource.deleteToken();
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Continue with local logout even if API call fails
    }
    await localDataSource.deleteToken();
    try {
      await remoteDataSource.signOutGoogle();
    } catch (_) {
      // Ignore if user was not signed in with Google (e.g. Apple user)
    }
  }
}
