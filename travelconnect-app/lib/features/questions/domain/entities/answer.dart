import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

class Answer extends Equatable {
  final int id;
  final String content;
  final double? averageRating;
  final int ratingsCount;
  final DateTime createdAt;
  final User? user;
  final int? userRating;

  const Answer({
    required this.id,
    required this.content,
    this.averageRating,
    required this.ratingsCount,
    required this.createdAt,
    this.user,
    this.userRating,
  });

  Answer copyWith({
    int? id,
    String? content,
    double? averageRating,
    int? ratingsCount,
    DateTime? createdAt,
    User? user,
    int? userRating,
  }) {
    return Answer(
      id: id ?? this.id,
      content: content ?? this.content,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      userRating: userRating ?? this.userRating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        averageRating,
        ratingsCount,
        createdAt,
        user,
        userRating,
      ];
}
