import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_question.dart';
import 'create_question_event.dart';
import 'create_question_state.dart';

class CreateQuestionBloc
    extends Bloc<CreateQuestionEvent, CreateQuestionState> {
  final CreateQuestion createQuestion;

  String _title = '';
  String _description = '';
  double _latitude = 0;
  double _longitude = 0;

  CreateQuestionBloc({
    required this.createQuestion,
    double initialLatitude = 0,
    double initialLongitude = 0,
  }) : super(const CreateQuestionInitial()) {
    _latitude = initialLatitude;
    _longitude = initialLongitude;

    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<LocationChanged>(_onLocationChanged);
    on<SubmitQuestion>(_onSubmitQuestion);
    on<ResetForm>(_onResetForm);

    // Emit initial form state
    if (initialLatitude != 0 || initialLongitude != 0) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(CreateQuestionFormEditing(
        title: '',
        description: '',
        latitude: initialLatitude,
        longitude: initialLongitude,
      ));
    }
  }

  void _onTitleChanged(
    TitleChanged event,
    Emitter<CreateQuestionState> emit,
  ) {
    _title = event.title;
    emit(_buildFormState());
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<CreateQuestionState> emit,
  ) {
    _description = event.description;
    emit(_buildFormState());
  }

  void _onLocationChanged(
    LocationChanged event,
    Emitter<CreateQuestionState> emit,
  ) {
    _latitude = event.latitude;
    _longitude = event.longitude;
    emit(_buildFormState());
  }

  Future<void> _onSubmitQuestion(
    SubmitQuestion event,
    Emitter<CreateQuestionState> emit,
  ) async {
    // Validate before submit
    String? titleError;
    if (_title.trim().isEmpty) {
      titleError = 'Le titre est requis';
    } else if (_title.trim().length < 3) {
      titleError = 'Le titre doit contenir au moins 3 caractères';
    }

    if (titleError != null) {
      emit(_buildFormState(titleError: titleError));
      return;
    }

    emit(const CreateQuestionSubmitting());

    try {
      final question = await createQuestion(CreateQuestionParams(
        title: _title.trim(),
        description: _description.trim().isEmpty ? null : _description.trim(),
        latitude: _latitude,
        longitude: _longitude,
      ));

      emit(CreateQuestionSuccess(question));
    } on DioException catch (e) {
      final message = _mapDioError(e);
      emit(CreateQuestionError(message));
    } catch (e) {
      emit(const CreateQuestionError(
        'Une erreur inattendue est survenue. Veuillez réessayer.',
      ));
    }
  }

  void _onResetForm(
    ResetForm event,
    Emitter<CreateQuestionState> emit,
  ) {
    _title = '';
    _description = '';
    emit(CreateQuestionFormEditing(
      title: '',
      description: '',
      latitude: _latitude,
      longitude: _longitude,
    ));
  }

  CreateQuestionFormEditing _buildFormState({String? titleError}) {
    return CreateQuestionFormEditing(
      title: _title,
      description: _description,
      latitude: _latitude,
      longitude: _longitude,
      titleError: titleError,
      descriptionError:
          _description.length > 500
              ? 'La description ne peut pas dépasser 500 caractères'
              : null,
    );
  }

  String _mapDioError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          return 'Session expirée. Veuillez vous reconnecter.';
        case 403:
          return 'Ce compte a été suspendu.';
        case 422:
          final errors = e.response!.data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
          return 'Données invalides. Vérifiez votre saisie.';
        case 429:
          return 'Vous avez atteint la limite de questions. Réessayez plus tard.';
        default:
          return 'Erreur serveur. Veuillez réessayer.';
      }
    }
    return 'Erreur de connexion. Vérifiez votre connexion internet.';
  }
}
