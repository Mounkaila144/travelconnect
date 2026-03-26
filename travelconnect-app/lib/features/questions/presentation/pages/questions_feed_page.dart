import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/questions_feed_bloc.dart';
import '../bloc/questions_feed_event.dart';
import '../bloc/questions_feed_state.dart';
import '../widgets/question_card.dart';
import '../../domain/entities/question.dart';

class QuestionsFeedPage extends StatefulWidget {
  const QuestionsFeedPage({super.key});

  @override
  State<QuestionsFeedPage> createState() => _QuestionsFeedPageState();
}

class _QuestionsFeedPageState extends State<QuestionsFeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<QuestionsFeedBloc>().add(const LoadQuestions());
    context.read<QuestionsFeedBloc>().add(const LoadPopularCities());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<QuestionsFeedBloc>().add(const LoadMoreQuestions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.questions_forum,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tappable search bar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.questions_search,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          _buildFilters(),
          Expanded(
            child: BlocBuilder<QuestionsFeedBloc, QuestionsFeedState>(
              builder: (context, state) {
                if (state is FeedLoading && state.questions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FeedError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl),
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
                            state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<QuestionsFeedBloc>()
                                  .add(const LoadQuestions());
                            },
                            child: Text(l10n.questions_retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<Question> questions = [];
                bool isLoadingMore = false;

                if (state is FeedLoaded) {
                  questions = state.questions;
                } else if (state is FeedLoading) {
                  questions = state.questions;
                  isLoadingMore = questions.isNotEmpty;
                }

                if (state is FeedLoaded && questions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: AppRadius.xxlAll,
                            ),
                            child: const Icon(
                              Icons.forum_outlined,
                              size: 40,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.questions_noQuestions,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<QuestionsFeedBloc>()
                        .add(const RefreshQuestions());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        questions.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= questions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final question = questions[index];
                      return QuestionCard(
                        question: question,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/question/${question.id}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<QuestionsFeedBloc, QuestionsFeedState>(
      builder: (context, state) {
        String currentSort = 'recent';
        String? currentCity;
        List<Map<String, dynamic>> popularCities = [];

        if (state is FeedLoaded) {
          currentSort = state.sort;
          currentCity = state.city;
          popularCities = state.popularCities;
        } else if (state is FeedLoading) {
          currentSort = state.sort;
          currentCity = state.city;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.questions_recent),
                selected: currentSort == 'recent',
                selectedColor: AppColors.primary.withAlpha(25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: currentSort == 'recent'
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: currentSort == 'recent'
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.xlAll,
                  side: BorderSide.none,
                ),
                onSelected: (_) {
                  context
                      .read<QuestionsFeedBloc>()
                      .add(const ChangeSortOrder('recent'));
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              FilterChip(
                label: Text(l10n.questions_popular),
                selected: currentSort == 'popular',
                selectedColor: AppColors.primary.withAlpha(25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: currentSort == 'popular'
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: currentSort == 'popular'
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.xlAll,
                  side: BorderSide.none,
                ),
                onSelected: (_) {
                  context
                      .read<QuestionsFeedBloc>()
                      .add(const ChangeSortOrder('popular'));
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              FilterChip(
                label: Text(currentCity ?? l10n.questions_allCities),
                selected: currentCity != null,
                selectedColor: AppColors.primary.withAlpha(25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: currentCity != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: currentCity != null
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.xlAll,
                  side: BorderSide.none,
                ),
                onSelected: (_) =>
                    _showCityPicker(context, popularCities, currentCity),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCityPicker(
    BuildContext context,
    List<Map<String, dynamic>> cities,
    String? currentCity,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.questions_filterByCity,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                title: Text(l10n.questions_allCities),
                selected: currentCity == null,
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<QuestionsFeedBloc>()
                      .add(const FilterByCity(null));
                },
              ),
              ...cities.map((city) => ListTile(
                    title: Text(city['city'] as String),
                    trailing: Text(
                      '${city['questions_count']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    selected: currentCity == city['city'],
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<QuestionsFeedBloc>().add(
                            FilterByCity(city['city'] as String),
                          );
                    },
                  )),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
