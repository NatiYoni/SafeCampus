import 'package:dio/dio.dart';
import '../models/campus_presence_model.dart';

abstract class CampusCompassRemoteDataSource {
  Future<void> sendHeartbeat(double lat, double lng, double heading, String status);
  Future<List<CampusPresenceModel>> getCampusStatus();
}

class CampusCompassRemoteDataSourceImpl implements CampusCompassRemoteDataSource {
  final Dio client;

  CampusCompassRemoteDataSourceImpl({required this.client});

  @override
  Future<void> sendHeartbeat(double lat, double lng, double heading, String status) async {
    await client.post(
      '/api/campus/heartbeat',
      data: {
        'latitude': lat,
        'longitude': lng,
        'heading': heading,
        'status': status,
      },
    );
  }

  @override
  Future<List<CampusPresenceModel>> getCampusStatus() async {
    final response = await client.get('/api/campus/status');
    final List<dynamic>? data = response.data;
    if (data == null) return [];
    return data.map((json) => CampusPresenceModel.fromJson(json)).toList();
  }
}
