import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/trust_score_display_widget.dart';
import '../../../moderation/presentation/widgets/report_button_widget.dart';
import '../../domain/entities/answer.dart';
import '../bloc/question_detail_bloc.dart';
import '../bloc/question_detail_event.dart';
import '../bloc/question_detail_state.dart';
import 'rating_stars_input_widget.dart';
import 'rating_stars_widget.dart';
import 'user_type_badge_widget.dart';

class AnswerItemWidget extends StatelessWidget {
  final Answer answer;
  final bool isOwnAnswer;

  const AnswerItemWidget({
    super.key,
    required this.answer,
    this.isOwnAnswer = false,
  });

  String _formatRelativeTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).languageCode;
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return DateFormat('d MMMM', locale).format(dateTime);
    }
    return timeago.format(dateTime, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLocal = answer.user?.userType == 'local_supporter';

    return Card(
      color: isLocal ? AppColors.successLight : AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: isLocal ? AppColors.success : AppColors.borderLight,
          width: isLocal ? 2 : 0.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdAll,
          border: Border(
            left: BorderSide(
              color: isLocal ? AppColors.success : AppColors.primary,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: answer.user?.avatarUrl != null
                        ? NetworkImage(answer.user!.avatarUrl!)
                        : null,
                    radius: 20,
                    child: answer.user?.avatarUrl == null
                        ? Text(
                            answer.user?.name.isNotEmpty == true
                                ? answer.user!.name[0].toUpperCase()
                                : '?',
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                answer.user?.name ?? l10n.questionDetail_user,
                                style: theme.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            if (answer.user != null)
                              UserTypeBadgeWidget(
                                  userType: answer.user!.userType),
                          ],
                        ),
                        Row(
                          children: [
                            if (answer.user != null) ...[
                              TrustScoreDisplayWidget(
                                score: answer.user!.trustScore,
                                isNew: answer.user!.isNew,
                                size: TrustScoreSize.small,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Flexible(
                              child: Text(
                                _formatRelativeTime(context, answer.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isOwnAnswer)
                    ReportButtonWidget(
                      reportableType: 'Answer',
                      reportableId: answer.id,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Answer content
              SelectableText(
                answer.content,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Rating section
              _buildRatingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (isOwnAnswer) {
      // Own answer: show read-only rating
      return Row(
        children: [
          Flexible(
            child: RatingStarsWidget(
              rating: answer.averageRating ?? 0,
              count: answer.ratingsCount,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              l10n.answerItem_yourAnswer,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    if (answer.userRating != null) {
      // User has already rated: show rating with edit option
      return Row(
        children: [
          Flexible(
            child: RatingStarsWidget(
              rating: answer.averageRating ?? 0,
              count: answer.ratingsCount,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => _showEditRating(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.info),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.info),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.answerItem_rated(answer.userRating!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.edit, size: 12, color: AppColors.info),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // User has not rated: show interactive stars
    return BlocBuilder<QuestionDetailBloc, QuestionDetailState>(
      buildWhen: (prev, curr) {
        if (prev is QuestionDetailLoaded && curr is QuestionDetailLoaded) {
          return prev.ratingAnswerId != curr.ratingAnswerId;
        }
        return true;
      },
      builder: (context, state) {
        final isRating = state is QuestionDetailLoaded &&
            state.ratingAnswerId == answer.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingStarsWidget(
              rating: answer.averageRating ?? 0,
              count: answer.ratingsCount,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  l10n.answerItem_rate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: RatingStarsInputWidget(
                    onRatingChanged: (score) {
                      context
                          .read<QuestionDetailBloc>()
                          .add(RateAnswerEvent(
                            answerId: answer.id,
                            score: score,
                          ));
                    },
                    isLoading: isRating,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showEditRating(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<QuestionDetailBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.answerItem_editRating),
        content: RatingStarsInputWidget(
          initialRating: answer.userRating,
          onRatingChanged: (score) {
            bloc.add(RateAnswerEvent(
              answerId: answer.id,
              score: score,
            ));
            Navigator.pop(dialogContext);
          },
          size: 36,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }
}
