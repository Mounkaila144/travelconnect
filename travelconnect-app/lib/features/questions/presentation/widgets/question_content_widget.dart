import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class QuestionContentWidget extends StatelessWidget {
  final String title;
  final String? description;

  const QuestionContentWidget({
    super.key,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
