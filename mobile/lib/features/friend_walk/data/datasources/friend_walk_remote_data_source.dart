import 'package:dio/dio.dart';
import '../models/walk_session_model.dart';
import '../../domain/entities/walk_session.dart';

abstract class FriendWalkRemoteDataSource {
  Future<WalkSessionModel> startWalk(String userId, String guardianId);
  Future<void> updateLocation(String walkId, double lat, double lng);
  Future<void> endWalk(String walkId);
  Future<List<WalkSessionModel>> getAllActiveWalks();
}

class FriendWalkRemoteDataSourceImpl implements FriendWalkRemoteDataSource {
  final Dio client;

  FriendWalkRemoteDataSourceImpl({required this.client});

  @override
  Future<WalkSessionModel> startWalk(String userId, String guardianId) async {
    final response = await client.post(
      '/api/walks/start',
      data: {
        'walker_id': userId,
        'guardian_id': guardianId,
      },
    );
    return WalkSessionModel.fromJson(response.data);
  }

  @override
  Future<void> updateLocation(String walkId, double lat, double lng) async {
    await client.post(
      '/api/walks/$walkId/location',
      data: {
        'lat': lat,
        'lng': lng,
      },
    );
  }

  @override
  Future<void> endWalk(String walkId) async {
    await client.post('/api/walks/$walkId/end');
  }

  @override
  Future<List<WalkSessionModel>> getAllActiveWalks() async {
    final response = await client.get('/api/walks/active');
    final List<dynamic>? data = response.data;
    if (data == null) return [];
    return data.map((json) => WalkSessionModel.fromJson(json)).toList();
  }
}
