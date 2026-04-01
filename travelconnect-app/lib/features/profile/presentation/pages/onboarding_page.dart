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

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Profile form state
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedUserType;
  String _selectedCountry = 'JP';
  File? _selectedImage;

  final List<Map<String, String>> _countries = kCountries;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToProfile() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (!state.profile.isNew) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with close and step indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage < 2)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _skipToProfile,
                      )
                    else
                      const SizedBox(width: AppSpacing.xxxl),
                    Text(
                      '${_currentPage + 1}/3',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxxl),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildSlide1(),
                    _buildSlide2(),
                    _buildProfileSlide(),
                  ],
                ),
              ),

              // Bottom section with dots and buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    // Pagination dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: isActive
                                ? AppRadius.xlAll
                                : BorderRadius.circular(4),
                            color: isActive
                                ? theme.colorScheme.primary
                                : AppColors.surfaceDim,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Button
                    if (_currentPage < 2) ...[
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.xlAll,
                            boxShadow: AppShadows.card,
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.xlAll,
                              ),
                            ),
                            child: Text(
                              l10n.onboarding_next,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _skipToProfile,
                        child: Text(
                          l10n.onboarding_skipIntro,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else ...[
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          final isLoading = state is ProfileLoading;
                          return SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: isLoading
                                    ? null
                                    : AppColors.primaryGradient,
                                color: isLoading
                                    ? AppColors.surfaceDim
                                    : null,
                                borderRadius: AppRadius.xlAll,
                                boxShadow:
                                    isLoading ? null : AppShadows.card,
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor:
                                      Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.xlAll,
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        l10n.onboarding_start,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Icon(
              Icons.public,
              size: 120,
              color: theme.colorScheme.primary.withAlpha(178),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            l10n.onboarding_slide1Title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboarding_slide1Subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Icon(
              Icons.map,
              size: 120,
              color: theme.colorScheme.primary.withAlpha(178),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            l10n.onboarding_slide2Title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboarding_slide2Subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSlide() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.onboarding_completeProfile,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Avatar
            Center(
              child: AvatarPicker(
                selectedImage: _selectedImage,
                onImageSelected: (file) {
                  setState(() => _selectedImage = file);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.onboarding_displayName,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return l10n.onboarding_nameTooShort;
                }
                if (value.trim().length > 50) {
                  return l10n.onboarding_nameTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // User type
            Text(
              l10n.onboarding_iAm,
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

            // Country
            CountryPickerFormField(
              value: _selectedCountry,
              onChanged: (value) {
                setState(() => _selectedCountry = value);
              },
              decoration: InputDecoration(
                labelText: l10n.onboarding_country,
                prefixIcon: const Icon(Icons.public),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Bio
            TextFormField(
              controller: _bioController,
              maxLength: 200,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.onboarding_bio,
                hintText: l10n.onboarding_bioHint,
                prefixIcon: const Icon(Icons.edit_note),
              ),
              validator: (value) {
                if (value != null && value.length > 200) {
                  return l10n.onboarding_bioTooLong;
                }
                return null;
              },
            ),
            // Extra space so the form doesn't get cut off by the bottom buttons
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.onboarding_selectUserType),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    // Upload avatar if selected
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
