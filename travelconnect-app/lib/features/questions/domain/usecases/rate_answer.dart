import 'package:equatable/equatable.dart';

import '../repositories/questions_repository.dart';

class RateAnswer {
  final QuestionsRepository repository;

  const RateAnswer(this.repository);

  Future<RatingResult> call(RateAnswerParams params) {
    return repository.rateAnswer(params: params);
  }
}

class RateAnswerParams extends Equatable {
  final int answerId;
  final int score;

  const RateAnswerParams({required this.answerId, required this.score});

  Map<String, dynamic> toJson() => {'score': score};

  @override
  List<Object?> get props => [answerId, score];
}

class RatingResult extends Equatable {
  final double averageRating;
  final int ratingsCount;

  const RatingResult({
    required this.averageRating,
    required this.ratingsCount,
  });

  factory RatingResult.fromJson(Map<String, dynamic> json) {
    return RatingResult(
      averageRating: (json['average_rating'] as num).toDouble(),
      ratingsCount: json['ratings_count'] as int,
    );
  }

  @override
  List<Object?> get props => [averageRating, ratingsCount];
}
