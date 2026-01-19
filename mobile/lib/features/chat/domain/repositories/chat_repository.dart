import '../entities/message.dart';

abstract class ChatRepository {
  Future<void> sendMessage(Message message);
  Future<List<Message>> getMessages(String reportId);
}
