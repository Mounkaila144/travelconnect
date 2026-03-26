import 'package:dio/dio.dart';

abstract class ReportRemoteDataSource {
  Future<void> createReport(Map<String, dynamic> data);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio dio;

  const ReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> createReport(Map<String, dynamic> data) async {
    await dio.post('/reports', data: data);
  }
}
