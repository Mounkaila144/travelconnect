import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/question.dart';
import 'answer_model.dart';

class QuestionModel {
  final int id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? city;
  final int answersCount;
  final bool hasAnswers;
  final bool hasUnreadAnswers;
  final double? distanceMeters;
  final DateTime createdAt;
  final Map<String, dynamic>? userData;
  final List<AnswerModel> answers;

  const QuestionModel({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.city,
    required this.answersCount,
    this.hasAnswers = false,
    this.hasUnreadAnswers = false,
    this.distanceMeters,
    required this.createdAt,
    this.userData,
    this.answers = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>?;

    return QuestionModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String?,
      city: json['city'] as String?,
      answersCount: json['answers_count'] as int? ?? 0,
      hasAnswers: json['has_answers'] as bool? ?? false,
      hasUnreadAnswers: json['has_unread_answers'] as bool? ?? false,
      distanceMeters: json['distance_meters'] != null
          ? (json['distance_meters'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      userData: json['user'] as Map<String, dynamic>?,
      answers: answersJson
              ?.map((a) => AnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Question toEntity() {
    User? user;
    if (userData != null) {
      user = User(
        id: userData!['id'] as int,
        email: userData!['email'] as String? ?? '',
        name: userData!['name'] as String,
        avatarUrl: userData!['avatar_url'] as String?,
        userType: userData!['user_type'] as String? ?? 'traveler',
        trustScore: (userData!['trust_score'] as num?)?.toDouble() ?? 0.0,
        isNew: false,
      );
    }

    return Question(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      city: city,
      answersCount: answersCount,
      hasUnreadAnswers: hasUnreadAnswers,
      distanceMeters: distanceMeters,
      createdAt: createdAt,
      user: user,
      answers: answers.map((a) => a.toEntity()).toList(),
    );
  }
}
