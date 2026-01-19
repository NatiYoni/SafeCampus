import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendMessage(Message message) async {
    final messageModel = MessageModel(
      id: message.id,
      reportId: message.reportId,
      senderId: message.senderId,
      content: message.content,
      timestamp: message.timestamp,
      isRead: message.isRead,
    );
    return await remoteDataSource.sendMessage(messageModel);
  }

  @override
  Future<List<Message>> getMessages(String reportId) async {
    return await remoteDataSource.getMessages(reportId);
  }
}
