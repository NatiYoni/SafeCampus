import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Future<List<Message>> call(String reportId) async {
    return await repository.getMessages(reportId);
  }
}
