import 'package:equatable/equatable.dart';

class WalkLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double heading;
  final DateTime timestamp;

  const WalkLocation({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, heading, timestamp];
}

class WalkSession extends Equatable {
  final String id;
  final String walkerId;
  final String guardianId;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime startTime;
  final WalkLocation currentLocation;

  const WalkSession({
    required this.id,
    required this.walkerId,
    required this.guardianId,
    required this.status,
    required this.startTime,
    required this.currentLocation,
  });

  @override
  List<Object?> get props => [id, walkerId, guardianId, status, startTime, currentLocation];
}
