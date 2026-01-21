import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/alert.dart';

abstract class EmergencyRemoteDataSource {
  Future<Alert> triggerSos(String userId);
  Future<void> cancelSos(String alertId);
  Future<List<Alert>> getAlerts();
  Future<Alert?> getMyActiveAlert();
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final Dio client;

  EmergencyRemoteDataSourceImpl({required this.client});

  @override
  Future<Alert?> getMyActiveAlert() async {
    try {
      final response = await client.get('/api/alerts/my-active');
      if (response.statusCode == 200 && response.data != null) {
        return Alert(
          id: response.data['id'],
          userId: response.data['user_id'],
          userName: response.data['user_name'],
          universityId: response.data['university_id'],
          type: AlertType.sos, 
          status: response.data['status'],
          timestamp: DateTime.parse(response.data['timestamp']),
          latitude: response.data['location']['latitude'],
          longitude: response.data['location']['longitude'],
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw e;
    }
  }

  @override
  Future<List<Alert>> getAlerts() async {
    final response = await client.get('/api/alerts/sos');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Alert(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'], // Map user_name
        universityId: json['university_id'],
        type: AlertType.sos, // Defaulting to SOS for now as it's the main one
        status: json['status'],
        timestamp: DateTime.parse(json['timestamp']),
        latitude: json['location']['latitude'],
        longitude: json['location']['longitude'],
      )).toList();
    } else {
      throw Exception('Failed to fetch alerts');
    }
  }

  @override
  Future<Alert> triggerSos(String userId) async {
    // 1. Get Current Location
    Position position = await _determinePosition();

    // 2. Send to Backend
    final response = await client.post(
      '/api/alerts/sos',
      data: jsonEncode({
        "user_id": userId,
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude
        }
      }),
    );

    if (response.statusCode == 201) {
      // Parse response to Alert model
      final data = response.data;
      return Alert(
        id: data['id'] ?? 'temp-id',
        userId: data['user_id'],
        userName: data['user_name'],
        universityId: data['university_id'],
        type: AlertType.sos,
        status: data['status'],
        timestamp: DateTime.parse(data['timestamp']),
        latitude: data['location']['latitude'],
        longitude: data['location']['longitude'],
      );
    } else {
      throw Exception('Failed to trigger SOS');
    }
  }

  @override
  Future<void> cancelSos(String alertId) async {
    // Backend API: api.PUT("/alerts/:id/resolve", alertHandler.ResolveAlert)
    final response = await client.put('/api/alerts/$alertId/resolve');
    
    if (response.statusCode != 200) {
       throw Exception('Failed to cancel SOS');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}
