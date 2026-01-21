import 'package:dio/dio.dart';
import '../models/mental_health_resource_model.dart';

abstract class MentalHealthRemoteDataSource {
  Future<List<MentalHealthResourceModel>> getResources();
}

class MentalHealthRemoteDataSourceImpl implements MentalHealthRemoteDataSource {
  final Dio client;

  MentalHealthRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MentalHealthResourceModel>> getResources() async {
    final response = await client.get('/api/mental-health');
    final List<dynamic> data = response.data;
    return data.map((json) => MentalHealthResourceModel.fromJson(json)).toList();
  }
}
