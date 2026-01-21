import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final String id;
  final String userId;
  final String? userName; // Added userName
  final String category;
  final String description;
  final bool isAnonymous;
  final String status;
  final DateTime timestamp;

  const Report({
    required this.id,
    required this.userId,
    this.userName,
    required this.category,
    required this.description,
    required this.isAnonymous,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, category, description, isAnonymous, status, timestamp];
}
