import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../moderation/presentation/widgets/report_button_widget.dart';
import '../../domain/entities/question.dart';
import '../bloc/question_detail_bloc.dart';
import '../bloc/question_detail_event.dart';
import '../bloc/question_detail_state.dart';
import '../widgets/answer_input_widget.dart';
import '../widgets/answers_list_widget.dart';
import '../widgets/question_content_widget.dart';
import '../widgets/question_header_widget.dart';
import '../widgets/question_location_map_widget.dart';

class QuestionDetailPage extends StatelessWidget {
  final int questionId;

  const QuestionDetailPage({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionDetail_title),
        actions: [
          BlocBuilder<QuestionDetailBloc, QuestionDetailState>(
            builder: (context, state) {
              if (state is QuestionDetailLoaded) {
                final authState = context.read<AuthBloc>().state;
                final currentUserId =
                    authState is Authenticated ? authState.user.id : null;
                final isOwnQuestion =
                    currentUserId != null && state.question.user?.id == currentUserId;
                if (!isOwnQuestion) {
                  return ReportButtonWidget(
                    reportableType: 'Question',
                    reportableId: state.question.id,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<QuestionDetailBloc, QuestionDetailState>(
        listener: (context, state) {
          if (state is QuestionDetailLoaded) {
            if (state.answerError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.answerError!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state.ratingSuccess != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.ratingSuccess!),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            if (state.ratingError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.ratingError!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is QuestionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuestionDetailError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<QuestionDetailBloc>()
                    .add(LoadQuestionDetail(questionId));
              },
            );
          }

          if (state is QuestionDetailLoaded) {
            final authState = context.read<AuthBloc>().state;
            final currentUserId =
                authState is Authenticated ? authState.user.id : null;
            return _QuestionDetailContent(
              question: state.question,
              isAnswerInputVisible: state.isAnswerInputVisible,
              isSubmittingAnswer: state.isSubmittingAnswer,
              currentUserId: currentUserId,
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          BlocBuilder<QuestionDetailBloc, QuestionDetailState>(
        builder: (context, state) {
          if (state is! QuestionDetailLoaded || state.isAnswerInputVisible) {
            return const SizedBox.shrink();
          }
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.lgAll,
              boxShadow: AppShadows.elevated,
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              highlightElevation: 0,
              onPressed: () {
                context
                    .read<QuestionDetailBloc>()
                    .add(const ShowAnswerInput());
              },
              icon: const Icon(Icons.reply),
              label: Text(l10n.questionDetail_reply),
            ),
          );
        },
      ),
    );
  }
}

class _QuestionDetailContent extends StatelessWidget {
  final Question question;
  final bool isAnswerInputVisible;
  final bool isSubmittingAnswer;
  final int? currentUserId;

  const _QuestionDetailContent({
    required this.question,
    required this.isAnswerInputVisible,
    required this.isSubmittingAnswer,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<QuestionDetailBloc>().add(const RefreshQuestion());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with author info
            if (question.user != null)
              QuestionHeaderWidget(
                user: question.user!,
                createdAt: question.createdAt,
              ),
            const SizedBox(height: AppSpacing.lg),

            // Question title and description
            QuestionContentWidget(
              title: question.title,
              description: question.description,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Mini-map with location
            QuestionLocationMapWidget(
              latitude: question.latitude,
              longitude: question.longitude,
              locationName: question.locationName,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Answer input widget
            if (isAnswerInputVisible)
              AnswerInputWidget(
                isSubmitting: isSubmittingAnswer,
                onSubmit: (content) {
                  context
                      .read<QuestionDetailBloc>()
                      .add(SubmitAnswer(content));
                },
                onCancel: () {
                  context
                      .read<QuestionDetailBloc>()
                      .add(const HideAnswerInput());
                },
              ),

            // Answers list
            AnswersListWidget(
              answers: question.answers,
              currentUserId: currentUserId,
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppRadius.xxlAll,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.questionDetail_retry),
            ),
          ],
        ),
      ),
    );
  }
}
