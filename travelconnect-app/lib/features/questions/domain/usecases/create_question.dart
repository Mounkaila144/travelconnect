import 'package:equatable/equatable.dart';

import '../entities/question.dart';
import '../repositories/questions_repository.dart';

class CreateQuestion {
  final QuestionsRepository repository;

  const CreateQuestion(this.repository);

  Future<Question> call(CreateQuestionParams params) {
    return repository.createQuestion(params: params);
  }
}

class CreateQuestionParams extends Equatable {
  final String title;
  final String? description;
  final double latitude;
  final double longitude;

  const CreateQuestionParams({
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [title, description, latitude, longitude];
}
