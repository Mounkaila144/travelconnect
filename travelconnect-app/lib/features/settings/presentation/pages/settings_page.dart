import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/locale/locale_bloc.dart';
import '../../../../core/locale/locale_event.dart';
import '../../../../core/locale/locale_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/logout_confirmation_dialog.dart';
import 'notification_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings_title),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          children: [
            // Account section
            _SectionHeader(title: l10n.settings_account),
            const SizedBox(height: AppSpacing.xs),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: const BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  ListTile(
                    leading: _buildIconContainer(Icons.person_outline, AppColors.primary),
                    title: Text(l10n.settings_editProfile),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed('/edit-profile');
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.shield_outlined, AppColors.primary),
                    title: Text(l10n.settings_privacy),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showComingSoon(context, l10n.settings_privacy);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Notifications section
            _SectionHeader(title: l10n.settings_notifications),
            const SizedBox(height: AppSpacing.xs),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: const BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: ListTile(
                leading: _buildIconContainer(Icons.notifications_outlined, AppColors.accent),
                title: Text(l10n.settings_notifications),
                subtitle: Text(
                  l10n.settings_manageNotifications,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<SettingsBloc>()
                          ..add(const LoadSettings()),
                        child: const NotificationSettingsPage(),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Preferences section
            _SectionHeader(title: l10n.settings_preferences),
            const SizedBox(height: AppSpacing.xs),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: const BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  BlocBuilder<LocaleBloc, LocaleState>(
                    builder: (context, localeState) {
                      final currentLang = switch (localeState.locale.languageCode) {
                        'fr' => l10n.settings_languageFrench,
                        'ja' => l10n.settings_languageJapanese,
                        _ => l10n.settings_languageEnglish,
                      };
                      return ListTile(
                        leading: _buildIconContainer(Icons.language, AppColors.secondary),
                        title: Text(l10n.settings_language),
                        subtitle: Text(
                          currentLang,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                        onTap: () {
                          _showLanguagePicker(context);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.straighten, AppColors.secondary),
                    title: Text(l10n.settings_distanceUnits),
                    subtitle: Text(
                      l10n.settings_kilometers,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showDistanceUnitPicker(context);
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.palette_outlined, AppColors.secondary),
                    title: Text(l10n.settings_theme),
                    subtitle: Text(
                      l10n.settings_themeSystem,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showThemePicker(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // About section
            _SectionHeader(title: l10n.settings_about),
            const SizedBox(height: AppSpacing.xs),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: const BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  ListTile(
                    leading: _buildIconContainer(Icons.info_outline, AppColors.info),
                    title: Text(l10n.settings_version),
                    subtitle: Text(
                      '1.0.0 (Build 100)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.help_outline, AppColors.info),
                    title: Text(l10n.settings_helpAndSupport),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showComingSoon(context, l10n.settings_helpAndSupport);
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.description_outlined, AppColors.info),
                    title: Text(l10n.settings_termsOfUse),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showComingSoon(context, l10n.settings_termsOfUse);
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.privacy_tip_outlined, AppColors.info),
                    title: Text(l10n.settings_privacyPolicy),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      _showComingSoon(context, l10n.settings_privacyPolicy);
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    leading: _buildIconContainer(Icons.code, AppColors.info),
                    title: Text(l10n.settings_openSourceLicenses),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'TravelConnect',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Logout button
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: BorderSide(color: AppColors.error.withAlpha(50), width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ListTile(
                    onTap: isLoading
                        ? null
                        : () async {
                            final confirmed =
                                await showLogoutConfirmationDialog(context);
                            if (confirmed && context.mounted) {
                              context
                                  .read<AuthBloc>()
                                  .add(const SignOutRequested());
                            }
                          },
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.logout, color: AppColors.error, size: 20),
                    ),
                    title: Text(
                      l10n.settings_logout,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Delete account button
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: BorderSide(color: AppColors.error.withAlpha(50), width: 0.5),
              ),
              color: AppColors.surfaceWhite,
              child: ListTile(
                onTap: () => _showDeleteAccountDialog(context),
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                ),
                title: Text(
                  l10n.settings_deleteAccount,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  static Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settings_comingSoon(feature)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.read<LocaleBloc>().state.locale;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settings_selectLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocaleBloc>().add(const ChangeLocale(Locale('fr')));
            },
            child: Row(
              children: [
                Expanded(child: Text(l10n.settings_languageFrench)),
                if (currentLocale.languageCode == 'fr')
                  Icon(Icons.check, color: theme.colorScheme.primary),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocaleBloc>().add(const ChangeLocale(Locale('en')));
            },
            child: Row(
              children: [
                Expanded(child: Text(l10n.settings_languageEnglish)),
                if (currentLocale.languageCode == 'en')
                  Icon(Icons.check, color: theme.colorScheme.primary),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocaleBloc>().add(const ChangeLocale(Locale('ja')));
            },
            child: Row(
              children: [
                Expanded(child: Text(l10n.settings_languageJapanese)),
                if (currentLocale.languageCode == 'ja')
                  Icon(Icons.check, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDistanceUnitPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settings_distanceUnits),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_kilometers),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_miles),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settings_theme),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_themeSystem),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_themeLight),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settings_themeDark),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_deleteAccountConfirm),
        content: Text(l10n.settings_deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settings_deleteAccountComingSoon),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
