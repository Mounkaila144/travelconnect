import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart' as uc;
import '../../domain/usecases/upload_avatar.dart' as uc;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final uc.UpdateProfile updateProfile;
  final uc.UploadAvatar uploadAvatar;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadAvatar,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await getProfile();
      emit(ProfileLoaded(profile: profile));
    } on DioException catch (e) {
      emit(ProfileError(message: _mapDioError(e)));
    } catch (e) {
      emit(const ProfileError(
          message: 'Erreur lors du chargement du profil.'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await updateProfile(
        name: event.name,
        bio: event.bio,
        countryCode: event.countryCode,
        userType: event.userType,
      );
      emit(ProfileLoaded(profile: profile));
    } on DioException catch (e) {
      emit(ProfileError(message: _mapDioError(e)));
    } catch (e) {
      emit(const ProfileError(
          message: 'Erreur lors de la mise à jour du profil.'));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(AvatarUploading(profile: currentState.profile));
    }

    try {
      final avatarUrl = await uploadAvatar(event.imageFile);

      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
          profile: currentState.profile.copyWith(avatarUrl: avatarUrl),
        ));
      } else {
        final profile = await getProfile();
        emit(ProfileLoaded(profile: profile));
      }
    } on DioException catch (e) {
      emit(ProfileError(
          message: _mapDioError(e)));
    } catch (e) {
      emit(const ProfileError(
          message: "Erreur lors de l'upload de la photo. Réessayez."));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 422) {
      final data = e.response?.data;
      if (data is Map && data['errors'] != null) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first as String;
        }
      }
      return 'Données invalides. Vérifiez les informations saisies.';
    }

    if (statusCode == 413) {
      return "L'image ne doit pas dépasser 5 Mo.";
    }

    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
