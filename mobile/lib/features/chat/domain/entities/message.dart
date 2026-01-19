import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String reportId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.reportId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  @override
  List<Object?> get props => [id, reportId, senderId, content, timestamp, isRead];
}
