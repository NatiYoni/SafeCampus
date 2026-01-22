import '../../domain/entities/campus_presence.dart';

class CampusPresenceModel extends CampusPresence {
  const CampusPresenceModel({
    required super.userId,
    required super.latitude,
    required super.longitude,
    required super.heading,
    required super.status,
    required super.lastSeen,
  });

  factory CampusPresenceModel.fromJson(Map<String, dynamic> json) {
    return CampusPresenceModel(
      userId: json['user_id'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      heading: (json['heading'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'safe',
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : DateTime.now(),
    );
  }
}
