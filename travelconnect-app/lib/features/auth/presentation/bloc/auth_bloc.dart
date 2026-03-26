import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide SignInWithApple;

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithAppleRequested>(_onSignInWithApple);
    on<SignOutRequested>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await signInWithGoogle();
      emit(Authenticated(user: result.user, isNewUser: result.isNewUser));
    } on AuthCancelledException {
      emit(const Unauthenticated());
    } on DioException catch (e) {
      emit(AuthError(_mapDioError(e)));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Google Sign-In error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      emit(const AuthError("Erreur d'authentification. Veuillez réessayer."));
    }
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await signInWithApple();
      emit(Authenticated(user: result.user, isNewUser: result.isNewUser));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        emit(const Unauthenticated());
      } else {
        emit(const AuthError(
            "Erreur d'identification Apple. Veuillez réessayer."));
      }
    } on AuthCancelledException {
      emit(const Unauthenticated());
    } on DioException catch (e) {
      emit(AuthError(_mapDioError(e)));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError("Erreur d'authentification. Veuillez réessayer."));
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.signOut();
    } catch (_) {
      // Always logout locally even if API call or cleanup fails
    }
    emit(const Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.restoreSession();
    if (result != null) {
      emit(Authenticated(user: result.user, isNewUser: result.isNewUser));
    } else {
      emit(const Unauthenticated());
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 403 &&
        data is Map &&
        data['error']?['code'] == 'USER_BANNED') {
      return 'Votre compte a été suspendu. Contactez le support.';
    }

    if (statusCode == 401) {
      return "Erreur d'authentification. Veuillez réessayer.";
    }

    return "Erreur d'authentification. Veuillez réessayer.";
  }
}
