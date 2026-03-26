import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travelconnect_app/features/auth/domain/entities/user.dart';
import 'package:travelconnect_app/features/profile/domain/usecases/get_profile.dart';
import 'package:travelconnect_app/features/profile/domain/usecases/update_profile.dart'
    as uc;
import 'package:travelconnect_app/features/profile/domain/usecases/upload_avatar.dart'
    as uc;
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:travelconnect_app/features/profile/presentation/bloc/profile_state.dart';

class MockGetProfile extends Mock implements GetProfile {}

class MockUpdateProfile extends Mock implements uc.UpdateProfile {}

class MockUploadAvatar extends Mock implements uc.UploadAvatar {}

class FakeFile extends Fake implements File {}

void main() {
  late MockGetProfile mockGetProfile;
  late MockUpdateProfile mockUpdateProfile;
  late MockUploadAvatar mockUploadAvatar;

  const testUser = User(
    id: 1,
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: null,
    bio: 'Test bio',
    countryCode: 'JP',
    userType: 'traveler',
    trustScore: 0.0,
    isNew: false,
    questionsCount: 5,
    answersCount: 12,
  );

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockGetProfile = MockGetProfile();
    mockUpdateProfile = MockUpdateProfile();
    mockUploadAvatar = MockUploadAvatar();
  });

  ProfileBloc buildBloc() => ProfileBloc(
        getProfile: mockGetProfile,
        updateProfile: mockUpdateProfile,
        uploadAvatar: mockUploadAvatar,
      );

  group('ProfileBloc', () {
    group('LoadProfile', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when LoadProfile succeeds',
        build: () {
          when(() => mockGetProfile()).thenAnswer((_) async => testUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileLoaded(profile: testUser),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when LoadProfile fails',
        build: () {
          when(() => mockGetProfile()).thenThrow(Exception('Network error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError(
              message: 'Erreur lors du chargement du profil.'),
        ],
      );
    });

    group('UpdateProfile', () {
      const updatedUser = User(
        id: 1,
        email: 'test@example.com',
        name: 'Updated Name',
        bio: 'New bio',
        countryCode: 'FR',
        userType: 'local_supporter',
        trustScore: 0.0,
        isNew: false,
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when UpdateProfile succeeds',
        build: () {
          when(() => mockUpdateProfile(
                name: 'Updated Name',
                bio: 'New bio',
                countryCode: 'FR',
                userType: 'local_supporter',
              )).thenAnswer((_) async => updatedUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const UpdateProfile(
          name: 'Updated Name',
          bio: 'New bio',
          countryCode: 'FR',
          userType: 'local_supporter',
        )),
        expect: () => [
          const ProfileLoading(),
          const ProfileLoaded(profile: updatedUser),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when UpdateProfile fails',
        build: () {
          when(() => mockUpdateProfile(
                name: any(named: 'name'),
                bio: any(named: 'bio'),
                countryCode: any(named: 'countryCode'),
                userType: any(named: 'userType'),
              )).thenThrow(Exception('Server error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const UpdateProfile(
          name: 'Name',
          countryCode: 'JP',
          userType: 'traveler',
        )),
        expect: () => [
          const ProfileLoading(),
          const ProfileError(
              message: 'Erreur lors de la mise à jour du profil.'),
        ],
      );
    });

    group('UploadAvatar', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [AvatarUploading, ProfileLoaded] when UploadAvatar succeeds from loaded state',
        build: () {
          when(() => mockUploadAvatar(any()))
              .thenAnswer((_) async => 'https://example.com/avatar.jpg');
          return buildBloc();
        },
        seed: () => const ProfileLoaded(profile: testUser),
        act: (bloc) => bloc.add(UploadAvatar(imageFile: FakeFile())),
        expect: () => [
          const AvatarUploading(profile: testUser),
          ProfileLoaded(
            profile: testUser.copyWith(
                avatarUrl: 'https://example.com/avatar.jpg'),
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits ProfileError when UploadAvatar fails',
        build: () {
          when(() => mockUploadAvatar(any())).thenThrow(Exception('Failed'));
          return buildBloc();
        },
        seed: () => const ProfileLoaded(profile: testUser),
        act: (bloc) => bloc.add(UploadAvatar(imageFile: FakeFile())),
        expect: () => [
          const AvatarUploading(profile: testUser),
          const ProfileError(
              message: "Erreur lors de l'upload de la photo. Réessayez."),
        ],
      );
    });
  });
}
