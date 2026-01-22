import 'package:dio/dio.dart';
import '../models/mental_health_resource_model.dart';

abstract class MentalHealthRemoteDataSource {
  Future<List<MentalHealthResourceModel>> getResources();
  Future<String> sendMessage(String message, List<Map<String, String>> history);
}

class MentalHealthRemoteDataSourceImpl implements MentalHealthRemoteDataSource {
  final Dio client;

  MentalHealthRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MentalHealthResourceModel>> getResources() async {
    final response = await client.get('/api/mental-health');
    final List<dynamic>? data = response.data;
    if (data == null) {
      return [];
    }
    return data.map((json) => MentalHealthResourceModel.fromJson(json)).toList();
  }

  @override
  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    final response = await client.post('/api/mental-health/chat', data: {
      'message': message,
      'history': history,
    });
    return response.data['response'];
  }
}

