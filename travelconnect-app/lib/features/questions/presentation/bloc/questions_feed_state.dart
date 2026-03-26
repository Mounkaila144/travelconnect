import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

abstract class QuestionsFeedState extends Equatable {
  const QuestionsFeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends QuestionsFeedState {
  const FeedInitial();
}

class FeedLoading extends QuestionsFeedState {
  final List<Question> questions;
  final String sort;
  final String? city;

  const FeedLoading({
    this.questions = const [],
    this.sort = 'recent',
    this.city,
  });

  @override
  List<Object?> get props => [questions, sort, city];
}

class FeedLoaded extends QuestionsFeedState {
  final List<Question> questions;
  final bool hasMore;
  final int currentPage;
  final String sort;
  final String? city;
  final List<Map<String, dynamic>> popularCities;

  const FeedLoaded({
    required this.questions,
    required this.hasMore,
    required this.currentPage,
    this.sort = 'recent',
    this.city,
    this.popularCities = const [],
  });

  @override
  List<Object?> get props =>
      [questions, hasMore, currentPage, sort, city, popularCities];

  FeedLoaded copyWith({
    List<Question>? questions,
    bool? hasMore,
    int? currentPage,
    String? sort,
    String? city,
    List<Map<String, dynamic>>? popularCities,
  }) {
    return FeedLoaded(
      questions: questions ?? this.questions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      sort: sort ?? this.sort,
      city: city,
      popularCities: popularCities ?? this.popularCities,
    );
  }
}

class FeedError extends QuestionsFeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
