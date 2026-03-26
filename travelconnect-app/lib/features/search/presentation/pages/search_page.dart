import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection.dart';
import '../../../questions/domain/entities/question.dart';
import '../../../questions/domain/repositories/questions_repository.dart';
import '../../../questions/presentation/bloc/question_detail_bloc.dart';
import '../../../questions/presentation/bloc/question_detail_event.dart';
import '../../../questions/presentation/pages/question_detail_page.dart';
import '../../../questions/domain/usecases/get_question_detail.dart';
import '../../../questions/domain/usecases/create_answer.dart';
import '../../../questions/domain/usecases/rate_answer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSearching = false;
  List<Question> _results = [];
  String? _error;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().length < 2) return;

    final l10n = AppLocalizations.of(context)!;

    // Add to recent searches
    setState(() {
      _recentSearches.remove(query.trim());
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
      _isSearching = true;
      _error = null;
    });

    try {
      final repository = sl<QuestionsRepository>();
      final result = await repository.getQuestionsFeed(
        sort: 'recent',
        city: null,
        page: 1,
      );

      // Filter results locally by query
      final query_ = query.trim().toLowerCase();
      final filtered = result.questions.where((q) {
        return q.title.toLowerCase().contains(query_) ||
            (q.description?.toLowerCase().contains(query_) ?? false) ||
            (q.city?.toLowerCase().contains(query_) ?? false) ||
            (q.locationName?.toLowerCase().contains(query_) ?? false);
      }).toList();

      if (mounted) {
        setState(() {
          _results = filtered;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l10n.search_loadError;
          _isSearching = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _error = null;
    });
    _focusNode.requestFocus();
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _clearHistory() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _navigateToQuestion(int questionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => QuestionDetailBloc(
            getQuestionDetail: sl<GetQuestionDetail>(),
            createAnswer: sl<CreateAnswer>(),
            rateAnswer: sl<RateAnswer>(),
          )..add(LoadQuestionDetail(questionId)),
          child: QuestionDetailPage(questionId: questionId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.xlAll,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: l10n.search_hint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    // Show loading
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(_error!),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
              child: Text(l10n.search_retry),
            ),
          ],
        ),
      );
    }

    // Show results
    if (_searchController.text.isNotEmpty && _results.isNotEmpty) {
      return _buildResults();
    }

    // Show no results
    if (_searchController.text.length >= 2 && _results.isEmpty && !_isSearching) {
      return _buildNoResults();
    }

    // Show recent searches
    return _buildRecentSearches();
  }

  Widget _buildRecentSearches() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.search_recentSearches.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _clearHistory,
                  child: Text(l10n.search_clearHistory),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _recentSearches.map((search) => InputChip(
                  label: Text(search),
                  avatar: const Icon(Icons.history, size: 16, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  onDeleted: () => _removeRecentSearch(search),
                  deleteIconColor: AppColors.textTertiary,
                  backgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.xlAll,
                  ),
                  side: BorderSide.none,
                )).toList(),
          ),
        ],
        if (_recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Icon(Icons.search, size: 64, color: AppColors.textTertiary.withAlpha(100)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.search_placeholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.sm),
          child: Text(
            l10n.search_resultsCount(_results.length).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._results.map((question) => _SearchResultCard(
              question: question,
              onTap: () => _navigateToQuestion(question.id),
            )),
      ],
    );
  }

  Widget _buildNoResults() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textTertiary.withAlpha(100)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.search_noResults,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.search_noResultsHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const _SearchResultCard({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      color: AppColors.surfaceWhite,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (question.locationName != null || question.city != null) ...[
                    Icon(Icons.location_on, size: 14, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        question.locationName ?? question.city ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${question.answersCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
