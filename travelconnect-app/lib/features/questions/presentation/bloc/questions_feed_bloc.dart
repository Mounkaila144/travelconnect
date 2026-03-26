import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/questions_repository.dart';
import 'questions_feed_event.dart';
import 'questions_feed_state.dart';

class QuestionsFeedBloc extends Bloc<QuestionsFeedEvent, QuestionsFeedState> {
  final QuestionsRepository questionsRepository;

  QuestionsFeedBloc({required this.questionsRepository})
      : super(const FeedInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<RefreshQuestions>(_onRefreshQuestions);
    on<LoadMoreQuestions>(_onLoadMoreQuestions);
    on<ChangeSortOrder>(_onChangeSortOrder);
    on<FilterByCity>(_onFilterByCity);
    on<LoadPopularCities>(_onLoadPopularCities);
  }

  String _currentSort = 'recent';
  String? _currentCity;
  List<Map<String, dynamic>> _popularCities = [];

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    emit(FeedLoading(sort: _currentSort, city: _currentCity));
    try {
      final result = await questionsRepository.getQuestionsFeed(
        sort: _currentSort,
        city: _currentCity,
        page: 1,
      );
      emit(FeedLoaded(
        questions: result.questions,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
        sort: _currentSort,
        city: _currentCity,
        popularCities: _popularCities,
      ));
    } catch (e, stackTrace) {
      debugPrint('[QUESTIONS] Error loading questions: $e');
      debugPrint('[QUESTIONS] Stack trace: $stackTrace');
      emit(const FeedError('Impossible de charger les questions'));
    }
  }

  Future<void> _onRefreshQuestions(
    RefreshQuestions event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    try {
      final result = await questionsRepository.getQuestionsFeed(
        sort: _currentSort,
        city: _currentCity,
        page: 1,
      );
      emit(FeedLoaded(
        questions: result.questions,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
        sort: _currentSort,
        city: _currentCity,
        popularCities: _popularCities,
      ));
    } catch (e) {
      emit(const FeedError('Erreur de rafraîchissement'));
    }
  }

  Future<void> _onLoadMoreQuestions(
    LoadMoreQuestions event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeedLoaded || !currentState.hasMore) return;

    try {
      final result = await questionsRepository.getQuestionsFeed(
        sort: _currentSort,
        city: _currentCity,
        page: currentState.currentPage + 1,
      );
      emit(FeedLoaded(
        questions: [...currentState.questions, ...result.questions],
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
        sort: _currentSort,
        city: _currentCity,
        popularCities: _popularCities,
      ));
    } catch (e) {
      // Keep current state on load more failure
    }
  }

  Future<void> _onChangeSortOrder(
    ChangeSortOrder event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    _currentSort = event.sort;
    emit(FeedLoading(sort: _currentSort, city: _currentCity));
    try {
      final result = await questionsRepository.getQuestionsFeed(
        sort: _currentSort,
        city: _currentCity,
        page: 1,
      );
      emit(FeedLoaded(
        questions: result.questions,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
        sort: _currentSort,
        city: _currentCity,
        popularCities: _popularCities,
      ));
    } catch (e) {
      emit(const FeedError('Impossible de charger les questions'));
    }
  }

  Future<void> _onFilterByCity(
    FilterByCity event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    _currentCity = event.city;
    emit(FeedLoading(sort: _currentSort, city: _currentCity));
    try {
      final result = await questionsRepository.getQuestionsFeed(
        sort: _currentSort,
        city: _currentCity,
        page: 1,
      );
      emit(FeedLoaded(
        questions: result.questions,
        hasMore: result.hasMorePages,
        currentPage: result.currentPage,
        sort: _currentSort,
        city: _currentCity,
        popularCities: _popularCities,
      ));
    } catch (e) {
      emit(const FeedError('Impossible de charger les questions'));
    }
  }

  Future<void> _onLoadPopularCities(
    LoadPopularCities event,
    Emitter<QuestionsFeedState> emit,
  ) async {
    try {
      _popularCities = await questionsRepository.getPopularCities();
      final currentState = state;
      if (currentState is FeedLoaded) {
        emit(currentState.copyWith(popularCities: _popularCities));
      }
    } catch (e) {
      // Silently fail for cities loading
    }
  }
}
