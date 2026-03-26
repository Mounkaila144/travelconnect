import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/trust_score_widget.dart';
import '../widgets/user_type_badge.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile_title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfile());
                    },
                    child: Text(l10n.profile_retry),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is AvatarUploading) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as AvatarUploading).profile;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Gradient header with avatar
                  SizedBox(
                    height: 200,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Gradient arc background
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: AppColors.headerGradient,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppRadius.xxl),
                              bottomRight: Radius.circular(AppRadius.xxl),
                            ),
                          ),
                        ),
                        // Avatar overlapping the gradient
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surfaceWhite,
                                  width: 3,
                                ),
                                boxShadow: AppShadows.elevated,
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: AppColors.surfaceDim,
                                backgroundImage: profile.avatarUrl != null
                                    ? NetworkImage(profile.avatarUrl!)
                                    : null,
                                child: profile.avatarUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 55,
                                        color: AppColors.textTertiary,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Name
                  Text(
                    profile.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // User type badge
                  UserTypeBadge(userType: profile.userType),
                  const SizedBox(height: AppSpacing.sm),

                  // Trust score
                  TrustScoreWidget(
                    trustScore: profile.trustScore,
                    isNew: profile.isNew,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bio
                  if (profile.bio != null && profile.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Text(
                        profile.bio!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Country
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.public,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        profile.countryCode,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Stats - 3 columns in cards
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: l10n.profile_questions,
                            count: profile.questionsCount,
                            icon: Icons.question_answer_outlined,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatItem(
                            label: l10n.profile_answers,
                            count: profile.answersCount,
                            icon: Icons.chat_bubble_outline,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatItem(
                            label: l10n.profile_helpful,
                            count: profile.helpfulCount,
                            icon: Icons.thumb_up_outlined,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Menu items
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        // Mes Questions
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.question_answer,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(l10n.profile_myQuestions),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (profile.questionsCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: AppRadius.mdAll,
                                    ),
                                    child: Text(
                                      '${profile.questionsCount}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                            onTap: () => Navigator.of(context)
                                .pushNamed('/user/questions'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Mes Reponses Utiles
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.thumb_up_outlined,
                              color: AppColors.secondary,
                            ),
                            title: Text(l10n.profile_myHelpfulAnswers),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (profile.helpfulCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: AppRadius.mdAll,
                                    ),
                                    child: Text(
                                      '${profile.helpfulCount}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.profile_myHelpfulAnswersComingSoon,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Edit button with gradient
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.mdAll,
                          boxShadow: AppShadows.card,
                        ),
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/edit-profile');
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.textOnPrimary,
                          ),
                          label: Text(
                            l10n.profile_editProfile,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
