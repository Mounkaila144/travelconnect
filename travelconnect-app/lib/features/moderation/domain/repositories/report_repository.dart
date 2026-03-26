import '../usecases/create_report.dart';

abstract class ReportRepository {
  Future<void> createReport({required CreateReportParams params});
}
