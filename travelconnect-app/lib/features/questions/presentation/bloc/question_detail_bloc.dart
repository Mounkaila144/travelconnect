import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_answer.dart';
import '../../domain/usecases/get_question_detail.dart';
import '../../domain/usecases/rate_answer.dart';
import 'question_detail_event.dart';
import 'question_detail_state.dart';

class QuestionDetailBloc
    extends Bloc<QuestionDetailEvent, QuestionDetailState> {
  final GetQuestionDetail getQuestionDetail;
  final CreateAnswer createAnswer;
  final RateAnswer rateAnswer;
  int? _questionId;

  QuestionDetailBloc({
    required this.getQuestionDetail,
    required this.createAnswer,
    required this.rateAnswer,
  }) : super(const QuestionDetailInitial()) {
    on<LoadQuestionDetail>(_onLoadQuestionDetail);
    on<RefreshQuestion>(_onRefreshQuestion);
    on<ShowAnswerInput>(_onShowAnswerInput);
    on<HideAnswerInput>(_onHideAnswerInput);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<RateAnswerEvent>(_onRateAnswer);
  }

  Future<void> _onLoadQuestionDetail(
    LoadQuestionDetail event,
    Emitter<QuestionDetailState> emit,
  ) async {
    _questionId = event.questionId;
    emit(const QuestionDetailLoading());

    try {
      final question = await getQuestionDetail(event.questionId);
      debugPrint('[DETAIL] Question ${question.id}: ${question.title}');
      debugPrint('[DETAIL] answers_count=${question.answersCount}, answers.length=${question.answers.length}');
      for (final a in question.answers) {
        debugPrint('[DETAIL] Answer #${a.id}: ${a.content.substring(0, a.content.length > 30 ? 30 : a.content.length)}');
      }
      emit(QuestionDetailLoaded(question));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(const QuestionDetailError("Cette question n'existe plus"));
      } else {
        emit(const QuestionDetailError('Erreur de connexion'));
      }
    } catch (e) {
      emit(const QuestionDetailError('Erreur de connexion'));
    }
  }

  Future<void> _onRefreshQuestion(
    RefreshQuestion event,
    Emitter<QuestionDetailState> emit,
  ) async {
    if (_questionId == null) return;

    try {
      final question = await getQuestionDetail(_questionId!);
      emit(QuestionDetailLoaded(question));
    } catch (_) {
      // Keep current state on refresh failure
    }
  }

  void _onShowAnswerInput(
    ShowAnswerInput event,
    Emitter<QuestionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is QuestionDetailLoaded) {
      emit(currentState.copyWith(
        isAnswerInputVisible: true,
        clearError: true,
      ));
    }
  }

  void _onHideAnswerInput(
    HideAnswerInput event,
    Emitter<QuestionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is QuestionDetailLoaded) {
      emit(currentState.copyWith(
        isAnswerInputVisible: false,
        clearError: true,
      ));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<QuestionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuestionDetailLoaded || _questionId == null) return;

    emit(currentState.copyWith(isSubmittingAnswer: true, clearError: true));

    try {
      final newAnswer = await createAnswer(CreateAnswerParams(
        questionId: _questionId!,
        content: event.content,
      ));

      debugPrint('[DETAIL] New answer created: id=${newAnswer.id}, content=${newAnswer.content}');
      debugPrint('[DETAIL] Existing answers: ${currentState.question.answers.length}');

      // Update question with new answer added to list
      final updatedQuestion = currentState.question.copyWith(
        answers: [newAnswer, ...currentState.question.answers],
        answersCount: currentState.question.answersCount + 1,
      );

      emit(QuestionDetailLoaded(
        updatedQuestion,
        isAnswerInputVisible: false,
        isSubmittingAnswer: false,
      ));
    } on DioException catch (e) {
      final message = e.response?.statusCode == 422
          ? 'Contenu invalide. Vérifiez votre réponse.'
          : 'Erreur de connexion. Réessayez.';
      emit(currentState.copyWith(
        isSubmittingAnswer: false,
        answerError: message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSubmittingAnswer: false,
        answerError: 'Erreur lors de l\'envoi. Réessayez.',
      ));
    }
  }

  Future<void> _onRateAnswer(
    RateAnswerEvent event,
    Emitter<QuestionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuestionDetailLoaded) return;

    emit(currentState.copyWith(
      ratingAnswerId: event.answerId,
      clearRating: true,
    ).copyWith(ratingAnswerId: event.answerId));

    try {
      final result = await rateAnswer(RateAnswerParams(
        answerId: event.answerId,
        score: event.score,
      ));

      final updatedAnswers = currentState.question.answers.map((answer) {
        if (answer.id == event.answerId) {
          return answer.copyWith(
            averageRating: result.averageRating,
            ratingsCount: result.ratingsCount,
            userRating: event.score,
          );
        }
        return answer;
      }).toList();

      final updatedQuestion = currentState.question.copyWith(
        answers: updatedAnswers,
      );

      emit(QuestionDetailLoaded(
        updatedQuestion,
        isAnswerInputVisible: currentState.isAnswerInputVisible,
        ratingSuccess: 'Note enregistrée',
      ));
    } on DioException catch (e) {
      String message;
      if (e.response?.statusCode == 403) {
        message = 'Vous ne pouvez pas noter votre propre réponse';
      } else {
        message = 'Erreur de connexion. Réessayez.';
      }
      emit(currentState.copyWith(
        clearRating: true,
      ).copyWith(ratingError: message));
    } catch (e) {
      emit(currentState.copyWith(
        clearRating: true,
      ).copyWith(ratingError: 'Erreur lors de la notation. Réessayez.'));
    }
  }
}
