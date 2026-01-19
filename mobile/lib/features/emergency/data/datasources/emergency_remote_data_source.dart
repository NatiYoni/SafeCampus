import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/alert.dart';

abstract class EmergencyRemoteDataSource {
  Future<Alert> triggerSos(String userId);
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final Dio client;

  EmergencyRemoteDataSourceImpl({required this.client});

  @override
  Future<Alert> triggerSos(String userId) async {
    // 1. Get Current Location
    Position position = await _determinePosition();

    // 2. Send to Backend
    final response = await client.post(
      '/alerts',
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
