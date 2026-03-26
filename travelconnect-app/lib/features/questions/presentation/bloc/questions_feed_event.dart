import 'package:equatable/equatable.dart';

abstract class QuestionsFeedEvent extends Equatable {
  const QuestionsFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestions extends QuestionsFeedEvent {
  const LoadQuestions();
}

class RefreshQuestions extends QuestionsFeedEvent {
  const RefreshQuestions();
}

class LoadMoreQuestions extends QuestionsFeedEvent {
  const LoadMoreQuestions();
}

class ChangeSortOrder extends QuestionsFeedEvent {
  final String sort;

  const ChangeSortOrder(this.sort);

  @override
  List<Object?> get props => [sort];
}

class FilterByCity extends QuestionsFeedEvent {
  final String? city;

  const FilterByCity(this.city);

  @override
  List<Object?> get props => [city];
}

class LoadPopularCities extends QuestionsFeedEvent {
  const LoadPopularCities();
}
