import 'package:equatable/equatable.dart';

class CampusPresence extends Equatable {
  final String userId;
  final double latitude;
  final double longitude;
  final double heading;
  final String status; // "safe" or "sos"
  final DateTime lastSeen;

  const CampusPresence({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.status,
    required this.lastSeen,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude, heading, status, lastSeen];
}
