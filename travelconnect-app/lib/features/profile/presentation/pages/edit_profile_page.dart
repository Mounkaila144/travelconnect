import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/country_picker.dart';
import '../widgets/user_type_selector.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedUserType;
  String _selectedCountry = 'JP';
  File? _selectedImage;
  bool _initialized = false;

  // New fields from design
  List<String> _selectedLanguages = [];
  List<String> _selectedInterests = [];

  static const List<Map<String, String>> _countries = kCountries;

  static const List<Map<String, String>> _availableLanguages = [
    {'code': 'ja', 'name': 'Japonais', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'Anglais', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Espagnol', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Allemand', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italien', 'flag': '🇮🇹'},
    {'code': 'zh', 'name': 'Chinois', 'flag': '🇨🇳'},
    {'code': 'ko', 'name': 'Coréen', 'flag': '🇰🇷'},
    {'code': 'pt', 'name': 'Portugais', 'flag': '🇧🇷'},
    {'code': 'th', 'name': 'Thaï', 'flag': '🇹🇭'},
  ];

  static const List<String> _availableInterests = [
    'Culture',
    'Gastronomie',
    'Nature',
    'Architecture',
    'Histoire',
    'Sport',
    'Musique',
    'Art',
    'Photographie',
    'Shopping',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initFromProfile(ProfileLoaded state) {
    if (!_initialized) {
      _nameController.text = state.profile.name;
      _bioController.text = state.profile.bio ?? '';
      _selectedUserType = state.profile.userType;
      _selectedCountry = state.profile.countryCode;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile_title),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isLoading = state is ProfileLoading;
              final isUploading = state is AvatarUploading;
              return TextButton(
                onPressed: (isLoading || isUploading) ? null : _onSave,
                child: Text(l10n.editProfile_save),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && _initialized) {
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded && !_initialized) {
            _initFromProfile(state);
          }

          final isLoading = state is ProfileLoading;
          final isUploading = state is AvatarUploading;
          final currentAvatarUrl = state is ProfileLoaded
              ? state.profile.avatarUrl
              : state is AvatarUploading
                  ? state.profile.avatarUrl
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar
                  Center(
                    child: AvatarPicker(
                      currentAvatarUrl: currentAvatarUrl,
                      selectedImage: _selectedImage,
                      isUploading: isUploading,
                      onImageSelected: (file) {
                        setState(() => _selectedImage = file);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Basic Info Section ---
                  Text(
                    l10n.editProfile_displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.editProfile_displayName,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return l10n.editProfile_nameTooShort;
                      }
                      if (value.trim().length > 50) {
                        return l10n.editProfile_nameTooLong;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bio
                  Text(
                    l10n.editProfile_bio,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _bioController,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.editProfile_bioHint,
                      prefixIcon: const Icon(Icons.edit_note),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 200) {
                        return l10n.editProfile_bioTooLong;
                      }
                      return null;
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Divider(),
                  ),

                  // --- User Type Section ---
                  Text(
                    l10n.editProfile_iAm,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  UserTypeSelector(
                    selectedType: _selectedUserType,
                    onSelected: (type) {
                      setState(() => _selectedUserType = type);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Localisation principale (only if Local)
                  if (_selectedUserType == 'local') ...[
                    Text(
                      l10n.editProfile_mainLocation,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CountryPickerFormField(
                      value: _countries.any((c) => c['code'] == _selectedCountry)
                          ? _selectedCountry
                          : 'JP',
                      onChanged: (value) {
                        setState(() => _selectedCountry = value);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ] else ...[
                    // Country for travelers
                    Text(
                      l10n.editProfile_country,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CountryPickerFormField(
                      value: _countries.any((c) => c['code'] == _selectedCountry)
                          ? _selectedCountry
                          : 'JP',
                      onChanged: (value) {
                        setState(() => _selectedCountry = value);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.public),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(),
                  ),

                  // --- Languages Section ---
                  Text(
                    l10n.editProfile_spokenLanguages,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ..._selectedLanguages.map((code) {
                        final lang = _availableLanguages.firstWhere(
                          (l) => l['code'] == code,
                          orElse: () =>
                              {'code': code, 'name': code, 'flag': '🌐'},
                        );
                        return Chip(
                          avatar: Text(lang['flag']!),
                          label: Text(lang['name']!),
                          backgroundColor:
                              AppColors.primary.withAlpha(25),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xlAll,
                          ),
                          onDeleted: () {
                            setState(
                                () => _selectedLanguages.remove(code));
                          },
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(l10n.editProfile_addLanguage),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.xlAll,
                        ),
                        side: BorderSide.none,
                        onPressed: _showLanguagePicker,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Divider(),
                  ),

                  // --- Interests Section ---
                  Text(
                    l10n.editProfile_interests,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ..._selectedInterests.map((interest) {
                        return Chip(
                          label: Text('#$interest'),
                          backgroundColor:
                              AppColors.primary.withAlpha(25),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xlAll,
                          ),
                          onDeleted: () {
                            setState(
                                () => _selectedInterests.remove(interest));
                          },
                        );
                      }),
                      if (_selectedInterests.length < 10)
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: Text(l10n.editProfile_addInterest),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xlAll,
                          ),
                          side: BorderSide.none,
                          onPressed: _showInterestPicker,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Save button with gradient
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: (isLoading || isUploading)
                            ? null
                            : AppColors.primaryGradient,
                        color: (isLoading || isUploading)
                            ? AppColors.surfaceDim
                            : null,
                        borderRadius: AppRadius.mdAll,
                        boxShadow: (isLoading || isUploading)
                            ? null
                            : AppShadows.card,
                      ),
                      child: ElevatedButton(
                        onPressed:
                            (isLoading || isUploading) ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                        child: (isLoading || isUploading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.editProfile_save,
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final available = _availableLanguages
        .where((l) => !_selectedLanguages.contains(l['code']))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              l10n.editProfile_selectLanguage,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ...available.map((lang) => ListTile(
                leading:
                    Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(lang['name']!),
                onTap: () {
                  setState(() => _selectedLanguages.add(lang['code']!));
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showInterestPicker() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final available = _availableInterests
        .where((i) => !_selectedInterests.contains(i))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              l10n.editProfile_selectInterest,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ...available.map((interest) => ListTile(
                leading: const Icon(Icons.tag),
                title: Text(interest),
                onTap: () {
                  setState(() => _selectedInterests.add(interest));
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload avatar if changed
    if (_selectedImage != null) {
      final resized = await resizeImage(_selectedImage!);
      context.read<ProfileBloc>().add(UploadAvatar(imageFile: resized));
    }

    // Update profile
    context.read<ProfileBloc>().add(UpdateProfile(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          countryCode: _selectedCountry,
          userType: _selectedUserType!,
        ));
  }
}
