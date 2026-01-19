import '../../domain/entities/safety_timer.dart';

class SafetyTimerModel extends SafetyTimer {
  const SafetyTimerModel({
    required super.id,
    required super.userId,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.durationMinutes,
  });

  factory SafetyTimerModel.fromJson(Map<String, dynamic> json) {
    return SafetyTimerModel(
      id: json['id'],
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'],
      durationMinutes: json['duration_minutes'],
    );
  }
}
