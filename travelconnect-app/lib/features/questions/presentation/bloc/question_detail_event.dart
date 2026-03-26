import 'package:equatable/equatable.dart';

abstract class QuestionDetailEvent extends Equatable {
  const QuestionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestionDetail extends QuestionDetailEvent {
  final int questionId;

  const LoadQuestionDetail(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class RefreshQuestion extends QuestionDetailEvent {
  const RefreshQuestion();
}

class ShowAnswerInput extends QuestionDetailEvent {
  const ShowAnswerInput();
}

class HideAnswerInput extends QuestionDetailEvent {
  const HideAnswerInput();
}

class SubmitAnswer extends QuestionDetailEvent {
  final String content;

  const SubmitAnswer(this.content);

  @override
  List<Object?> get props => [content];
}

class RateAnswerEvent extends QuestionDetailEvent {
  final int answerId;
  final int score;

  const RateAnswerEvent({required this.answerId, required this.score});

  @override
  List<Object?> get props => [answerId, score];
}
