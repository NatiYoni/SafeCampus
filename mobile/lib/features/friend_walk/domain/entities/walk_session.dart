import 'package:equatable/equatable.dart';

class WalkSession extends Equatable {
  final String id;
  final String userId;
  final String guardianId;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime startTime;

  const WalkSession({
    required this.id,
    required this.userId,
    required this.guardianId,
    required this.status,
    required this.startTime,
  });

  @override
  List<Object?> get props => [id, userId, guardianId, status, startTime];
}
