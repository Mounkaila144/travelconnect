import '../../../auth/domain/entities/user.dart';

class UserProfileModel extends User {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    super.bio,
    super.countryCode,
    required super.userType,
    required super.trustScore,
    required super.isNew,
    super.questionsCount,
    super.answersCount,
    super.helpfulCount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      countryCode: (json['country_code'] as String?) ?? 'JP',
      userType: json['user_type'] as String,
      trustScore: (json['trust_score'] as num).toDouble(),
      isNew: json['is_new'] as bool,
      questionsCount: (json['questions_count'] as int?) ?? 0,
      answersCount: (json['answers_count'] as int?) ?? 0,
      helpfulCount: (json['helpful_count'] as int?) ?? 0,
    );
  }
}
