import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

abstract class CreateQuestionState extends Equatable {
  const CreateQuestionState();

  @override
  List<Object?> get props => [];
}

class CreateQuestionInitial extends CreateQuestionState {
  const CreateQuestionInitial();
}

class CreateQuestionFormEditing extends CreateQuestionState {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? titleError;
  final String? descriptionError;

  const CreateQuestionFormEditing({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.titleError,
    this.descriptionError,
  });

  bool get isValid =>
      title.trim().isNotEmpty &&
      title.length <= 100 &&
      description.length <= 500 &&
      titleError == null &&
      descriptionError == null;

  CreateQuestionFormEditing copyWith({
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? titleError,
    String? descriptionError,
    bool clearTitleError = false,
    bool clearDescriptionError = false,
  }) {
    return CreateQuestionFormEditing(
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        latitude,
        longitude,
        titleError,
        descriptionError,
      ];
}

class CreateQuestionSubmitting extends CreateQuestionState {
  const CreateQuestionSubmitting();
}

class CreateQuestionSuccess extends CreateQuestionState {
  final Question question;

  const CreateQuestionSuccess(this.question);

  @override
  List<Object?> get props => [question];
}

class CreateQuestionError extends CreateQuestionState {
  final String message;

  const CreateQuestionError(this.message);

  @override
  List<Object?> get props => [message];
}
