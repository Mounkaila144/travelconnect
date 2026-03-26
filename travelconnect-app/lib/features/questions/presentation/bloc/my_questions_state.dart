import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

abstract class MyQuestionsState extends Equatable {
  const MyQuestionsState();

  @override
  List<Object?> get props => [];
}

class MyQuestionsInitial extends MyQuestionsState {
  const MyQuestionsInitial();
}

class MyQuestionsLoading extends MyQuestionsState {
  const MyQuestionsLoading();
}

class MyQuestionsLoaded extends MyQuestionsState {
  final List<Question> questions;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const MyQuestionsLoaded({
    required this.questions,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  MyQuestionsLoaded copyWith({
    List<Question>? questions,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MyQuestionsLoaded(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [questions, currentPage, hasMore, isLoadingMore];
}

class MyQuestionsError extends MyQuestionsState {
  final String message;

  const MyQuestionsError(this.message);

  @override
  List<Object?> get props => [message];
}
