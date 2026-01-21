import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../../domain/entities/report.dart';

abstract class ReportingRemoteDataSource {
  Future<ReportModel> createReport(String userId, String category, String description, bool isAnonymous);
}

class ReportingRemoteDataSourceImpl implements ReportingRemoteDataSource {
  final Dio client;

  ReportingRemoteDataSourceImpl({required this.client});

  @override
  Future<ReportModel> createReport(String userId, String category, String description, bool isAnonymous) async {
    final response = await client.post(
      '/api/reports',
      data: {
        'user_id': userId,
        'category': category,
        'description': description,
        'is_anonymous': isAnonymous,
      },
    );
    return ReportModel.fromJson(response.data);
  }
}
