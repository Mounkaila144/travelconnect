import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String countryCode;
  final String userType;
  final double trustScore;
  final bool isNew;
  final int questionsCount;
  final int answersCount;
  final int helpfulCount;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.countryCode = 'JP',
    required this.userType,
    required this.trustScore,
    required this.isNew,
    this.questionsCount = 0,
    this.answersCount = 0,
    this.helpfulCount = 0,
  });

  User copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    String? countryCode,
    String? userType,
    double? trustScore,
    bool? isNew,
    int? questionsCount,
    int? answersCount,
    int? helpfulCount,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      countryCode: countryCode ?? this.countryCode,
      userType: userType ?? this.userType,
      trustScore: trustScore ?? this.trustScore,
      isNew: isNew ?? this.isNew,
      questionsCount: questionsCount ?? this.questionsCount,
      answersCount: answersCount ?? this.answersCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        bio,
        countryCode,
        userType,
        trustScore,
        isNew,
        questionsCount,
        answersCount,
        helpfulCount,
      ];
}
