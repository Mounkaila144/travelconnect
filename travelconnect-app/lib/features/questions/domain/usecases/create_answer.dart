import 'package:equatable/equatable.dart';

import '../entities/answer.dart';
import '../repositories/questions_repository.dart';

class CreateAnswer {
  final QuestionsRepository repository;

  const CreateAnswer(this.repository);

  Future<Answer> call(CreateAnswerParams params) {
    return repository.createAnswer(params: params);
  }
}

class CreateAnswerParams extends Equatable {
  final int questionId;
  final String content;

  const CreateAnswerParams({
    required this.questionId,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
      };

  @override
  List<Object?> get props => [questionId, content];
}
