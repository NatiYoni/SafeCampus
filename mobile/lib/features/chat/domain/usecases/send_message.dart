import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call(Message message) async {
    return await repository.sendMessage(message);
  }
}
