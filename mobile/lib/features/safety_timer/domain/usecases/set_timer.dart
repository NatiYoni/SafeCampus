import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/safety_timer.dart';
import '../repositories/safety_timer_repository.dart';

class SetTimer implements UseCase<SafetyTimer, SetTimerParams> {
  final SafetyTimerRepository repository;

  SetTimer(this.repository);

  @override
  Future<Either<Failure, SafetyTimer>> call(SetTimerParams params) async {
    return await repository.setTimer(params.userId, params.durationMinutes, params.guardians);
  }
}

class SetTimerParams {
  final String userId;
  final int durationMinutes;
  final List<String> guardians;

  SetTimerParams({required this.userId, required this.durationMinutes, required this.guardians});
}

class CancelTimer implements UseCase<void, String> {
  final SafetyTimerRepository repository;
  CancelTimer(this.repository);

  @override
  Future<Either<Failure, void>> call(String timerId) async {
    return await repository.cancelTimer(timerId);
  }
}
