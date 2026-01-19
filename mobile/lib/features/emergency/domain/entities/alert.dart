import 'package:equatable/equatable.dart';

enum AlertType { sos, manDown, medical, fire, fall }

class Alert extends Equatable {
  final String id;
  final String userId;
  final AlertType type;
  final String status;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  const Alert({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [id, userId, type, status, timestamp, latitude, longitude];
}
