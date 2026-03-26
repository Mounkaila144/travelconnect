import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReport extends ReportEvent {
  final String reportableType;
  final int reportableId;
  final String reason;
  final String? comment;

  const SubmitReport({
    required this.reportableType,
    required this.reportableId,
    required this.reason,
    this.comment,
  });

  @override
  List<Object?> get props => [reportableType, reportableId, reason, comment];
}
