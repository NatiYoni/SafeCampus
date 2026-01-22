import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../../domain/entities/report.dart';

abstract class ReportingRemoteDataSource {
  Future<ReportModel> createReport(String userId, String category, String description, bool isAnonymous);
  Future<List<ReportModel>> getReports();
  Future<void> resolveReport(String id);
}

class ReportingRemoteDataSourceImpl implements ReportingRemoteDataSource {
  final Dio client;

  ReportingRemoteDataSourceImpl({required this.client});

  @override
  Future<ReportModel> createReport(String userId, String category, String description, bool isAnonymous) async {
    // If not anonymous, ensure user_id comes from interceptor/context, but here we pass it.
    // However, if we are using the interceptor, we might not need to manually send it if the backend extracts it.
    // The current backend handlers usually extract from Context.
    // If isAnonymous is true, we might want to send empty userId or specific flag.
    
    final response = await client.post(
      '/api/reports',
      data: {
        'category': category,
        'description': description,
        'is_anonymous': isAnonymous,
        // Backend middleware will extract user_id from token if available. 
        // We don't strictly need to send 'user_id' in body if backend uses context.
        // But for explicit compatibility with 'domain.Report' binding:
        'user_id': userId, 
      },
    );
    return ReportModel.fromJson(response.data);
  }

  @override
  Future<List<ReportModel>> getReports() async {
    final response = await client.get('/api/reports');
    return (response.data as List).map((e) => ReportModel.fromJson(e)).toList();
  }

  @override
  Future<void> resolveReport(String id) async {
    await client.put('/api/reports/$id/resolve');
  }
}
