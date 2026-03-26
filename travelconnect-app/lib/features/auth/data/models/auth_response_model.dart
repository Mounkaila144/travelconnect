import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class UserModel extends User {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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

class AuthResponseModel {
  final UserModel user;
  final String token;
  final bool isNewUser;

  const AuthResponseModel({
    required this.user,
    required this.token,
    required this.isNewUser,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      isNewUser: json['is_new_user'] as bool,
    );
  }

  AuthResult toAuthResult() {
    return AuthResult(
      user: user,
      token: token,
      isNewUser: isNewUser,
    );
  }
}
