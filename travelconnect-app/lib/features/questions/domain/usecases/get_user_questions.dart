import '../repositories/questions_repository.dart';

class GetUserQuestions {
  final QuestionsRepository repository;

  const GetUserQuestions(this.repository);

  Future<QuestionsResult> call({int page = 1}) {
    return repository.getUserQuestions(page: page);
  }
}
