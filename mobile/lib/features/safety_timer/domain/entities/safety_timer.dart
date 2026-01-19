import 'package:equatable/equatable.dart';

class SafetyTimer extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int durationMinutes;

  const SafetyTimer({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.durationMinutes,
  });

  @override
  List<Object> get props => [id, userId, startTime, endTime, status, durationMinutes];
}
