import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../domain/usecases/get_user_questions.dart';
import '../bloc/my_questions_bloc.dart';
import '../bloc/my_questions_event.dart';
import '../bloc/my_questions_state.dart';
import '../widgets/question_list_item_widget.dart';

class MyQuestionsPage extends StatelessWidget {
  const MyQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyQuestionsBloc(
        getUserQuestions: sl<GetUserQuestions>(),
      )..add(const LoadMyQuestions()),
      child: const _MyQuestionsView(),
    );
  }
}

class _MyQuestionsView extends StatefulWidget {
  const _MyQuestionsView();

  @override
  State<_MyQuestionsView> createState() => _MyQuestionsViewState();
}

class _MyQuestionsViewState extends State<_MyQuestionsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<MyQuestionsBloc>().state;
      if (state is MyQuestionsLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<MyQuestionsBloc>().add(const LoadMoreMyQuestions());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myQuestions_title),
        centerTitle: true,
      ),
      body: BlocBuilder<MyQuestionsBloc, MyQuestionsState>(
        builder: (context, state) {
          if (state is MyQuestionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyQuestionsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<MyQuestionsBloc>()
                            .add(const LoadMyQuestions());
                      },
                      child: Text(l10n.myQuestions_retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyQuestionsLoaded) {
            if (state.questions.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<MyQuestionsBloc>()
                    .add(const RefreshMyQuestions());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: state.questions.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.questions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final question = state.questions[index];
                  return QuestionListItemWidget(
                    question: question,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        '/question/detail',
                        arguments: question.id,
                      );
                      if (context.mounted) {
                        context
                            .read<MyQuestionsBloc>()
                            .add(MarkQuestionAsRead(question.id));
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_answer_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.myQuestions_empty,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.myQuestions_emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/question/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.myQuestions_askQuestion),
            ),
          ],
        ),
      ),
    );
  }
}
