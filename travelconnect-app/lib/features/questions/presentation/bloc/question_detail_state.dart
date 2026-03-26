import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

abstract class QuestionDetailState extends Equatable {
  const QuestionDetailState();

  @override
  List<Object?> get props => [];
}

class QuestionDetailInitial extends QuestionDetailState {
  const QuestionDetailInitial();
}

class QuestionDetailLoading extends QuestionDetailState {
  const QuestionDetailLoading();
}

class QuestionDetailLoaded extends QuestionDetailState {
  final Question question;
  final bool isAnswerInputVisible;
  final bool isSubmittingAnswer;
  final String? answerError;
  final int? ratingAnswerId;
  final String? ratingError;
  final String? ratingSuccess;

  const QuestionDetailLoaded(
    this.question, {
    this.isAnswerInputVisible = false,
    this.isSubmittingAnswer = false,
    this.answerError,
    this.ratingAnswerId,
    this.ratingError,
    this.ratingSuccess,
  });

  QuestionDetailLoaded copyWith({
    Question? question,
    bool? isAnswerInputVisible,
    bool? isSubmittingAnswer,
    String? answerError,
    int? ratingAnswerId,
    String? ratingError,
    String? ratingSuccess,
    bool clearError = false,
    bool clearRating = false,
  }) {
    return QuestionDetailLoaded(
      question ?? this.question,
      isAnswerInputVisible: isAnswerInputVisible ?? this.isAnswerInputVisible,
      isSubmittingAnswer: isSubmittingAnswer ?? this.isSubmittingAnswer,
      answerError: clearError ? null : (answerError ?? this.answerError),
      ratingAnswerId: clearRating ? null : (ratingAnswerId ?? this.ratingAnswerId),
      ratingError: clearRating ? null : (ratingError ?? this.ratingError),
      ratingSuccess: clearRating ? null : (ratingSuccess ?? this.ratingSuccess),
    );
  }

  @override
  List<Object?> get props => [
        question,
        isAnswerInputVisible,
        isSubmittingAnswer,
        answerError,
        ratingAnswerId,
        ratingError,
        ratingSuccess,
      ];
}

class QuestionDetailError extends QuestionDetailState {
  final String message;

  const QuestionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
