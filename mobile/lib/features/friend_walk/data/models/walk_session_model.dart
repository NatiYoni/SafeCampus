import '../../domain/entities/walk_session.dart';

class WalkSessionModel extends WalkSession {
  const WalkSessionModel({
    required super.id,
    required super.userId,
    required super.guardianId,
    required super.status,
    required super.startTime,
  });

  factory WalkSessionModel.fromJson(Map<String, dynamic> json) {
    return WalkSessionModel(
      id: json['id'],
      userId: json['user_id'],
      guardianId: json['guardian_id'],
      status: json['status'],
      startTime: DateTime.parse(json['start_time']),
    );
  }
  
  // toMap implementation if needed
}
