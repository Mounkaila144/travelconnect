import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/answer_model.dart';
import '../models/paginated_response.dart';
import '../models/question_model.dart';

abstract class QuestionsRemoteDataSource {
  Future<PaginatedResponse<QuestionModel>> getNearbyQuestions({
    required double lat,
    required double lng,
    required int radiusKm,
    int page = 1,
  });

  Future<PaginatedResponse<QuestionModel>> getQuestionsFeed({
    required String sort,
    String? city,
    int page = 1,
  });

  Future<List<Map<String, dynamic>>> getPopularCities();

  Future<PaginatedResponse<QuestionModel>> getUserQuestions({
    int page = 1,
  });

  Future<QuestionModel> createQuestion(Map<String, dynamic> data);

  Future<QuestionModel> getQuestionDetail(int id);

  Future<AnswerModel> createAnswer(int questionId, Map<String, dynamic> data);

  Future<Map<String, dynamic>> rateAnswer(int answerId, Map<String, dynamic> data);
}

class QuestionsRemoteDataSourceImpl implements QuestionsRemoteDataSource {
  final Dio dio;

  QuestionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedResponse<QuestionModel>> getNearbyQuestions({
    required double lat,
    required double lng,
    required int radiusKm,
    int page = 1,
  }) async {
    final response = await dio.get('/questions', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radiusKm,
      'page': page,
    });

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => QuestionModel.fromJson(json),
    );
  }

  @override
  Future<PaginatedResponse<QuestionModel>> getQuestionsFeed({
    required String sort,
    String? city,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'sort': sort,
      'page': page,
    };
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }

    final response = await dio.get('/questions', queryParameters: queryParams);

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => QuestionModel.fromJson(json),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularCities() async {
    final response = await dio.get('/questions/cities');
    final data = response.data as Map<String, dynamic>;
    final cities = data['data'] as List<dynamic>;
    return cities
        .map((c) => c as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<PaginatedResponse<QuestionModel>> getUserQuestions({
    int page = 1,
  }) async {
    final response = await dio.get('/user/questions', queryParameters: {
      'page': page,
    });

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => QuestionModel.fromJson(json),
    );
  }

  @override
  Future<QuestionModel> createQuestion(Map<String, dynamic> data) async {
    final response = await dio.post('/questions', data: data);

    return QuestionModel.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<QuestionModel> getQuestionDetail(int id) async {
    final response = await dio.get('/questions/$id');

    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final answersRaw = data['answers'];
    debugPrint('[DATASOURCE] getQuestionDetail($id) - answers key type: ${answersRaw.runtimeType}');
    debugPrint('[DATASOURCE] getQuestionDetail($id) - answers: $answersRaw');

    return QuestionModel.fromJson(data);
  }

  @override
  Future<AnswerModel> createAnswer(int questionId, Map<String, dynamic> data) async {
    final response = await dio.post('/questions/$questionId/answers', data: data);

    return AnswerModel.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<Map<String, dynamic>> rateAnswer(int answerId, Map<String, dynamic> data) async {
    final response = await dio.post('/answers/$answerId/rate', data: data);

    return response.data as Map<String, dynamic>;
  }
}
