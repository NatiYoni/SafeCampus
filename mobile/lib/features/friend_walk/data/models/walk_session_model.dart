import '../../domain/entities/walk_session.dart';

class WalkLocationModel extends WalkLocation {
  const WalkLocationModel({
    required super.latitude,
    required super.longitude,
    required super.heading,
    required super.timestamp,
  });

  factory WalkLocationModel.fromJson(Map<String, dynamic> json) {
    return WalkLocationModel(
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
      heading: (json['heading'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}

class WalkSessionModel extends WalkSession {
  const WalkSessionModel({
    required super.id,
    required super.walkerId,
    required super.guardianId,
    required super.status,
    required super.startTime,
    required super.currentLocation,
  });

  factory WalkSessionModel.fromJson(Map<String, dynamic> json) {
    return WalkSessionModel(
      id: json['id'],
      walkerId: json['walker_id'],
      guardianId: json['guardian_id'],
      status: json['status'],
      startTime: DateTime.parse(json['start_time']),
      currentLocation: json['current_location'] != null
          ? WalkLocationModel.fromJson(json['current_location'])
          : WalkLocationModel(latitude: 0, longitude: 0, heading: 0, timestamp: DateTime.fromMicrosecondsSinceEpoch(0)),
    );
  }
}
