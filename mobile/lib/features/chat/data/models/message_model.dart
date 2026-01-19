import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String reportId,
    required String senderId,
    required String content,
    required DateTime timestamp,
    required bool isRead,
  }) : super(
          id: id,
          reportId: reportId,
          senderId: senderId,
          content: content,
          timestamp: timestamp,
          isRead: isRead,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '', // ID might be empty for new messages
      reportId: json['report_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}
