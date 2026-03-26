import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> getGoogleIdToken();
  Future<AuthResponseModel> authenticateWithBackend(String idToken);
  Future<AuthResponseModel> authenticateAppleWithBackend({
    required String identityToken,
    required String authorizationCode,
    Map<String, String>? fullName,
  });
  Future<AppleSignInResult> getAppleCredentials();
  Future<void> signOutGoogle();
  Future<void> logout();
}

class AppleSignInResult {
  final String identityToken;
  final String authorizationCode;
  final Map<String, String>? fullName;

  const AppleSignInResult({
    required this.identityToken,
    required this.authorizationCode,
    this.fullName,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.googleSignIn,
  });

  @override
  Future<String> getGoogleIdToken() async {
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw const AuthCancelledException();
    }

    final authentication = await account.authentication;
    // On web, idToken is null; use accessToken as fallback
    final token = authentication.idToken ?? authentication.accessToken;
    if (token == null) {
      throw const AuthException('Impossible de récupérer le token Google');
    }

    return token;
  }

  @override
  Future<AuthResponseModel> authenticateWithBackend(String idToken) async {
    final response = await dio.post(
      '/auth/google',
      data: {'id_token': idToken},
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AppleSignInResult> getAppleCredentials() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      throw const AuthException('Apple Sign-In is only available on iOS');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw const AuthException("Impossible de récupérer le token Apple");
    }

    final authorizationCode = credential.authorizationCode;

    Map<String, String>? fullName;
    if (credential.givenName != null || credential.familyName != null) {
      fullName = {
        if (credential.givenName != null) 'given_name': credential.givenName!,
        if (credential.familyName != null)
          'family_name': credential.familyName!,
      };
    }

    return AppleSignInResult(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      fullName: fullName,
    );
  }

  @override
  Future<AuthResponseModel> authenticateAppleWithBackend({
    required String identityToken,
    required String authorizationCode,
    Map<String, String>? fullName,
  }) async {
    final response = await dio.post(
      '/auth/apple',
      data: {
        'identity_token': identityToken,
        'authorization_code': authorizationCode,
        if (fullName != null) 'full_name': fullName,
      },
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }

  @override
  Future<void> logout() async {
    await dio.post('/auth/logout');
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}
