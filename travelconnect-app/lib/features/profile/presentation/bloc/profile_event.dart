import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? bio;
  final String countryCode;
  final String userType;

  const UpdateProfile({
    required this.name,
    this.bio,
    required this.countryCode,
    required this.userType,
  });

  @override
  List<Object?> get props => [name, bio, countryCode, userType];
}

class UploadAvatar extends ProfileEvent {
  final File imageFile;

  const UploadAvatar({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}
