import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/safety_timer_repository.dart';

class CancelTimer implements UseCase<void, String> {
  final SafetyTimerRepository repository;

  CancelTimer(this.repository);

  @override
  Future<Either<Failure, void>> call(String timerId) async {
    return await repository.cancelTimer(timerId);
  }
}

