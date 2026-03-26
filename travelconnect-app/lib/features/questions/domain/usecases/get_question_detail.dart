import '../../domain/entities/question.dart';
import '../../domain/repositories/questions_repository.dart';

class GetQuestionDetail {
  final QuestionsRepository repository;

  GetQuestionDetail(this.repository);

  Future<Question> call(int id) {
    return repository.getQuestionDetail(id: id);
  }
}
