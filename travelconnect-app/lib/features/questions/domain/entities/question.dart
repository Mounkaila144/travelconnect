import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import 'answer.dart';

class Question extends Equatable {
  final int id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? city;
  final int answersCount;
  final bool hasUnreadAnswers;
  final double? distanceMeters;
  final DateTime createdAt;
  final User? user;
  final List<Answer> answers;

  const Question({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.city,
    required this.answersCount,
    this.hasUnreadAnswers = false,
    this.distanceMeters,
    required this.createdAt,
    this.user,
    this.answers = const [],
  });

  bool get hasAnswers => answersCount > 0;
  bool get needsAnswer => answersCount == 0;

  Question copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    String? city,
    int? answersCount,
    bool? hasUnreadAnswers,
    double? distanceMeters,
    DateTime? createdAt,
    User? user,
    List<Answer>? answers,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      city: city ?? this.city,
      answersCount: answersCount ?? this.answersCount,
      hasUnreadAnswers: hasUnreadAnswers ?? this.hasUnreadAnswers,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      answers: answers ?? this.answers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        latitude,
        longitude,
        locationName,
        city,
        answersCount,
        hasUnreadAnswers,
        distanceMeters,
        createdAt,
        user,
        answers,
      ];
}
