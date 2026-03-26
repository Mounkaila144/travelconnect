import 'package:equatable/equatable.dart';

abstract class MyQuestionsEvent extends Equatable {
  const MyQuestionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyQuestions extends MyQuestionsEvent {
  const LoadMyQuestions();
}

class RefreshMyQuestions extends MyQuestionsEvent {
  const RefreshMyQuestions();
}

class LoadMoreMyQuestions extends MyQuestionsEvent {
  const LoadMoreMyQuestions();
}

class MarkQuestionAsRead extends MyQuestionsEvent {
  final int questionId;

  const MarkQuestionAsRead(this.questionId);

  @override
  List<Object?> get props => [questionId];
}
