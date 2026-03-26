import '../entities/answer.dart';
import '../entities/question.dart';
import '../usecases/create_answer.dart';
import '../usecases/create_question.dart';
import '../usecases/rate_answer.dart';

abstract class QuestionsRepository {
  Future<QuestionsResult> getNearbyQuestions({
    required double latitude,
    required double longitude,
    required int radiusKm,
    int page = 1,
  });

  Future<QuestionsResult> getQuestionsFeed({
    required String sort,
    String? city,
    int page = 1,
  });

  Future<List<Map<String, dynamic>>> getPopularCities();

  Future<QuestionsResult> getUserQuestions({
    int page = 1,
  });

  Future<Question> createQuestion({
    required CreateQuestionParams params,
  });

  Future<Question> getQuestionDetail({
    required int id,
  });

  Future<Answer> createAnswer({
    required CreateAnswerParams params,
  });

  Future<RatingResult> rateAnswer({
    required RateAnswerParams params,
  });
}

class QuestionsResult {
  final List<Question> questions;
  final bool hasMorePages;
  final int currentPage;
  final int total;

  const QuestionsResult({
    required this.questions,
    required this.hasMorePages,
    required this.currentPage,
    required this.total,
  });
}
