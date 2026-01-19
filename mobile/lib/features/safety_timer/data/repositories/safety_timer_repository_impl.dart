import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/safety_timer.dart';
import '../../domain/repositories/safety_timer_repository.dart';
import '../datasources/safety_timer_remote_data_source.dart';

class SafetyTimerRepositoryImpl implements SafetyTimerRepository {
  final SafetyTimerRemoteDataSource remoteDataSource;

  SafetyTimerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SafetyTimer>> setTimer(String userId, int durationMinutes, List<String> guardians) async {
    try {
      final timer = await remoteDataSource.setTimer(userId, durationMinutes, guardians);
      return Right(timer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTimer(String timerId) async {
    try {
      await remoteDataSource.cancelTimer(timerId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
