import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/create_report.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  const ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createReport({required CreateReportParams params}) async {
    await remoteDataSource.createReport(params.toJson());
  }
}
