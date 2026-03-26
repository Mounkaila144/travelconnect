import 'package:equatable/equatable.dart';

abstract class CreateQuestionEvent extends Equatable {
  const CreateQuestionEvent();

  @override
  List<Object?> get props => [];
}

class TitleChanged extends CreateQuestionEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class DescriptionChanged extends CreateQuestionEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class LocationChanged extends CreateQuestionEvent {
  final double latitude;
  final double longitude;

  const LocationChanged(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class SubmitQuestion extends CreateQuestionEvent {
  const SubmitQuestion();
}

class ResetForm extends CreateQuestionEvent {
  const ResetForm();
}
