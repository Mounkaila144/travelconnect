import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/answer.dart';
import 'answer_item_widget.dart';

class AnswersListWidget extends StatelessWidget {
  final List<Answer> answers;
  final int? currentUserId;

  const AnswersListWidget({
    super.key,
    required this.answers,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Réponses (${answers.length})',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        if (answers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'Aucune réponse',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: answers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final answer = answers[index];
              return AnswerItemWidget(
                answer: answer,
                isOwnAnswer: currentUserId != null &&
                    answer.user?.id == currentUserId,
              );
            },
          ),
      ],
    );
  }
}
