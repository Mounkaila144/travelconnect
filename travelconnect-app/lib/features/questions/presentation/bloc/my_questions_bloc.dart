import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/question.dart';
import '../../domain/usecases/get_user_questions.dart';
import 'my_questions_event.dart';
import 'my_questions_state.dart';

class MyQuestionsBloc extends Bloc<MyQuestionsEvent, MyQuestionsState> {
  final GetUserQuestions getUserQuestions;

  MyQuestionsBloc({required this.getUserQuestions})
      : super(const MyQuestionsInitial()) {
    on<LoadMyQuestions>(_onLoadMyQuestions);
    on<RefreshMyQuestions>(_onRefreshMyQuestions);
    on<LoadMoreMyQuestions>(_onLoadMoreMyQuestions);
    on<MarkQuestionAsRead>(_onMarkQuestionAsRead);
  }

  Future<void> _onLoadMyQuestions(
    LoadMyQuestions event,
    Emitter<MyQuestionsState> emit,
  ) async {
    emit(const MyQuestionsLoading());

    try {
      final result = await getUserQuestions(page: 1);
      emit(MyQuestionsLoaded(
        questions: result.questions,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
      ));
    } on DioException catch (_) {
      emit(const MyQuestionsError(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      ));
    } catch (_) {
      emit(const MyQuestionsError(
        'Erreur serveur. Veuillez réessayer plus tard.',
      ));
    }
  }

  Future<void> _onRefreshMyQuestions(
    RefreshMyQuestions event,
    Emitter<MyQuestionsState> emit,
  ) async {
    try {
      final result = await getUserQuestions(page: 1);
      emit(MyQuestionsLoaded(
        questions: result.questions,
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
      ));
    } catch (_) {
      // Keep current state on refresh failure
    }
  }

  Future<void> _onLoadMoreMyQuestions(
    LoadMoreMyQuestions event,
    Emitter<MyQuestionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MyQuestionsLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await getUserQuestions(page: nextPage);

      emit(MyQuestionsLoaded(
        questions: [...currentState.questions, ...result.questions],
        currentPage: result.currentPage,
        hasMore: result.hasMorePages,
      ));
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void _onMarkQuestionAsRead(
    MarkQuestionAsRead event,
    Emitter<MyQuestionsState> emit,
  ) {
    final currentState = state;
    if (currentState is! MyQuestionsLoaded) return;

    final updatedQuestions = currentState.questions.map((q) {
      if (q.id == event.questionId) {
        return Question(
          id: q.id,
          title: q.title,
          description: q.description,
          latitude: q.latitude,
          longitude: q.longitude,
          locationName: q.locationName,
          city: q.city,
          answersCount: q.answersCount,
          hasUnreadAnswers: false,
          distanceMeters: q.distanceMeters,
          createdAt: q.createdAt,
          user: q.user,
          answers: q.answers,
        );
      }
      return q;
    }).toList();

    emit(currentState.copyWith(questions: updatedQuestions));
  }
}
