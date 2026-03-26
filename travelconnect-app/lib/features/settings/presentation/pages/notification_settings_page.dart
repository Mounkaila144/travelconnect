import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../bloc/notification_zone_bloc.dart';
import '../bloc/notification_zone_event.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import 'notification_zone_page.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings_title),
        centerTitle: true,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              children: [
                _SectionHeader(title: l10n.notificationSettings_preferences),
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
                      SwitchListTile(
                        title: Text(l10n.notificationSettings_newAnswers),
                        subtitle: Text(
                          l10n.notificationSettings_newAnswersDesc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(25),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: const Icon(Icons.question_answer_outlined, color: AppColors.accent, size: 20),
                        ),
                        value: state.settings['new_answers'] ?? true,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                UpdateNotificationSetting('new_answers', value),
                              );
                        },
                      ),
                      const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                      SwitchListTile(
                        title: Text(l10n.notificationSettings_nearbyQuestions),
                        subtitle: Text(
                          l10n.notificationSettings_nearbyQuestionsDesc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(25),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 20),
                        ),
                        value: state.settings['nearby_questions'] ?? true,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                UpdateNotificationSetting('nearby_questions', value),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                _SectionHeader(title: l10n.notificationSettings_zoneSection),
                const SizedBox(height: AppSpacing.xs),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgAll,
                    side: const BorderSide(color: AppColors.borderLight, width: 0.5),
                  ),
                  color: AppColors.surfaceWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.info.withAlpha(25),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: const Icon(Icons.map_outlined, color: AppColors.info, size: 20),
                        ),
                        title: Text(l10n.notificationSettings_configureZone),
                        subtitle: Text(
                          l10n.notificationSettings_configureZoneDesc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<NotificationZoneBloc>()
                                  ..add(const LoadNotificationZone()),
                                child: const NotificationZonePage(),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                        child: Text(
                          l10n.notificationSettings_maxPerDay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.notificationSettings_loadError),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    context.read<SettingsBloc>().add(const LoadSettings());
                  },
                  child: Text(l10n.notificationSettings_retry),
                ),
              ],
            ),
          );
        },
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
