import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/trust_score_colors.dart';
import 'trust_score_explanation_dialog.dart';

enum TrustScoreSize { small, medium, large }

class TrustScoreDisplayWidget extends StatelessWidget {
  final double score;
  final bool isNew;
  final TrustScoreSize size;
  final bool showExplanation;

  const TrustScoreDisplayWidget({
    super.key,
    required this.score,
    required this.isNew,
    this.size = TrustScoreSize.medium,
    this.showExplanation = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = isNew ? _buildNewBadge() : _buildScoreBadge();

    if (showExplanation) {
      return GestureDetector(
        onTap: () => _showExplanationDialog(context),
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildNewBadge() {
    final badgeSize = _getBadgeSize();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: badgeSize.paddingH,
        vertical: badgeSize.paddingV,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.infoLight,
            AppColors.info.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.info, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: badgeSize.iconSize,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Nouveau',
            style: TextStyle(
              fontSize: badgeSize.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge() {
    final badgeSize = _getBadgeSize();
    final color = TrustScoreColors.getColorForScore(score);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: badgeSize.paddingH,
        vertical: badgeSize.paddingV,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: badgeSize.iconSize,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: badgeSize.fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeSize _getBadgeSize() {
    switch (size) {
      case TrustScoreSize.small:
        return const _BadgeSize(
          fontSize: 11,
          iconSize: 14,
          paddingH: 6,
          paddingV: 3,
        );
      case TrustScoreSize.medium:
        return const _BadgeSize(
          fontSize: 14,
          iconSize: 18,
          paddingH: 8,
          paddingV: 4,
        );
      case TrustScoreSize.large:
        return const _BadgeSize(
          fontSize: 18,
          iconSize: 24,
          paddingH: 12,
          paddingV: 6,
        );
    }
  }

  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TrustScoreExplanationDialog(
        userScore: isNew ? null : score,
        isNew: isNew,
      ),
    );
  }
}

class _BadgeSize {
  final double fontSize;
  final double iconSize;
  final double paddingH;
  final double paddingV;

  const _BadgeSize({
    required this.fontSize,
    required this.iconSize,
    required this.paddingH,
    required this.paddingV,
  });
}
