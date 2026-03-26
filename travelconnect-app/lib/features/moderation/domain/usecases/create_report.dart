import 'package:equatable/equatable.dart';

import '../repositories/report_repository.dart';

class CreateReport {
  final ReportRepository repository;

  const CreateReport(this.repository);

  Future<void> call(CreateReportParams params) {
    return repository.createReport(params: params);
  }
}

class CreateReportParams extends Equatable {
  final String reportableType;
  final int reportableId;
  final String reason;
  final String? comment;

  const CreateReportParams({
    required this.reportableType,
    required this.reportableId,
    required this.reason,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'reportable_type': reportableType,
        'reportable_id': reportableId,
        'reason': reason,
        if (comment != null) 'comment': comment,
      };

  @override
  List<Object?> get props => [reportableType, reportableId, reason, comment];
}
