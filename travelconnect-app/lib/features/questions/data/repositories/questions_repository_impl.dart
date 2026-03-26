import '../datasources/questions_remote_datasource.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/questions_repository.dart';
import '../../domain/usecases/create_answer.dart';
import '../../domain/usecases/create_question.dart';
import '../../domain/usecases/rate_answer.dart';

class QuestionsRepositoryImpl implements QuestionsRepository {
  final QuestionsRemoteDataSource remoteDataSource;

  QuestionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<QuestionsResult> getNearbyQuestions({
    required double latitude,
    required double longitude,
    required int radiusKm,
    int page = 1,
  }) async {
    final response = await remoteDataSource.getNearbyQuestions(
      lat: latitude,
      lng: longitude,
      radiusKm: radiusKm,
      page: page,
    );

    final questions = response.data.map((model) => model.toEntity()).toList();

    return QuestionsResult(
      questions: questions,
      hasMorePages: response.hasMorePages,
      currentPage: response.currentPage,
      total: response.total,
    );
  }

  @override
  Future<QuestionsResult> getQuestionsFeed({
    required String sort,
    String? city,
    int page = 1,
  }) async {
    final response = await remoteDataSource.getQuestionsFeed(
      sort: sort,
      city: city,
      page: page,
    );

    final questions = response.data.map((model) => model.toEntity()).toList();

    return QuestionsResult(
      questions: questions,
      hasMorePages: response.hasMorePages,
      currentPage: response.currentPage,
      total: response.total,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularCities() async {
    return await remoteDataSource.getPopularCities();
  }

  @override
  Future<QuestionsResult> getUserQuestions({
    int page = 1,
  }) async {
    final response = await remoteDataSource.getUserQuestions(page: page);

    final questions = response.data.map((model) => model.toEntity()).toList();

    return QuestionsResult(
      questions: questions,
      hasMorePages: response.hasMorePages,
      currentPage: response.currentPage,
      total: response.total,
    );
  }

  @override
  Future<Question> createQuestion({
    required CreateQuestionParams params,
  }) async {
    final model = await remoteDataSource.createQuestion(params.toJson());
    return model.toEntity();
  }

  @override
  Future<Question> getQuestionDetail({required int id}) async {
    final model = await remoteDataSource.getQuestionDetail(id);
    return model.toEntity();
  }

  @override
  Future<Answer> createAnswer({required CreateAnswerParams params}) async {
    final model = await remoteDataSource.createAnswer(
      params.questionId,
      params.toJson(),
    );
    return model.toEntity();
  }

  @override
  Future<RatingResult> rateAnswer({required RateAnswerParams params}) async {
    final json = await remoteDataSource.rateAnswer(
      params.answerId,
      params.toJson(),
    );
    return RatingResult.fromJson(json);
  }
}
