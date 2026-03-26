import '../repositories/questions_repository.dart';

class GetNearbyQuestions {
  final QuestionsRepository repository;

  const GetNearbyQuestions(this.repository);

  Future<QuestionsResult> call({
    required double latitude,
    required double longitude,
    required int radiusKm,
    int page = 1,
  }) {
    return repository.getNearbyQuestions(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      page: page,
    );
  }
}
