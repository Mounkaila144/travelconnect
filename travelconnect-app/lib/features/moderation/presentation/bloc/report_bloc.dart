import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_report.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final CreateReport createReport;

  ReportBloc({required this.createReport}) : super(const ReportInitial()) {
    on<SubmitReport>(_onSubmitReport);
  }

  Future<void> _onSubmitReport(
    SubmitReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportSubmitting());

    try {
      await createReport(
        CreateReportParams(
          reportableType: event.reportableType,
          reportableId: event.reportableId,
          reason: event.reason,
          comment: event.comment,
        ),
      );

      emit(const ReportSubmitted());
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map && data['error'] != null) {
          emit(ReportError(data['error']['message'] ?? 'Erreur de validation'));
        } else {
          emit(const ReportError('Vous avez déjà signalé ce contenu'));
        }
      } else {
        emit(const ReportError('Erreur de connexion. Réessayez.'));
      }
    } catch (e) {
      emit(const ReportError('Une erreur est survenue'));
    }
  }
}
