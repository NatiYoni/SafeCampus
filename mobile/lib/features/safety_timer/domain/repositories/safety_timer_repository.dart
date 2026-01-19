import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/safety_timer.dart';

abstract class SafetyTimerRepository {
  Future<Either<Failure, SafetyTimer>> setTimer(String userId, int durationMinutes, List<String> guardians);
  Future<Either<Failure, void>> cancelTimer(String timerId);
}
