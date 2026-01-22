import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/mental_health_repository.dart';

class SendChatToCompanion implements UseCase<String, ChatParams> {
  final MentalHealthRepository repository;

  SendChatToCompanion(this.repository);

  @override
  Future<Either<Failure, String>> call(ChatParams params) async {
    return await repository.sendChatToCompanion(params.message, params.history);
  }
}

class ChatParams {
  final String message;
  final List<Map<String, String>> history;

  ChatParams({required this.message, required this.history});
}
