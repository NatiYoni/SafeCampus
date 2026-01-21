import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/alert.dart';

abstract class EmergencyRemoteDataSource {
  Future<Alert> triggerSos(String userId);
  Future<void> cancelSos(String alertId);
  Future<List<Alert>> getAlerts();
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final Dio client;

  EmergencyRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Alert>> getAlerts() async {
    final response = await client.get('/api/alerts/sos');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Alert(
        id: json['id'],
        userId: json['user_id'],
        userName: json['user_name'], // Map user_name
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
    final response = await client.delete('/api/alerts/$alertId');
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
