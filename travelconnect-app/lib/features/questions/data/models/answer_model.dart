import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/answer.dart';

class AnswerModel {
  final int id;
  final String content;
  final double? averageRating;
  final int ratingsCount;
  final DateTime createdAt;
  final Map<String, dynamic>? userData;
  final int? userRating;

  const AnswerModel({
    required this.id,
    required this.content,
    this.averageRating,
    required this.ratingsCount,
    required this.createdAt,
    this.userData,
    this.userRating,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as int,
      content: json['content'] as String,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      ratingsCount: json['ratings_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      userData: json['user'] as Map<String, dynamic>?,
      userRating: json['user_rating'] as int?,
    );
  }

  Answer toEntity() {
    User? user;
    if (userData != null) {
      user = User(
        id: userData!['id'] as int,
        email: userData!['email'] as String? ?? '',
        name: userData!['name'] as String,
        avatarUrl: userData!['avatar_url'] as String?,
        userType: userData!['user_type'] as String? ?? 'traveler',
        trustScore: (userData!['trust_score'] as num?)?.toDouble() ?? 0.0,
        isNew: userData!['is_new'] as bool? ?? false,
      );
    }

    return Answer(
      id: id,
      content: content,
      averageRating: averageRating,
      ratingsCount: ratingsCount,
      createdAt: createdAt,
      user: user,
      userRating: userRating,
    );
  }
}
