import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_data_source.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource remoteDataSource;

  EmergencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Alert>> triggerSos(String userId) async {
    try {
      final alert = await remoteDataSource.triggerSos(userId);
      return Right(alert);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSos(String alertId) async {
    try {
      await remoteDataSource.cancelSos(alertId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Alert>>> getAlerts() async {
    try {
      final alerts = await remoteDataSource.getAlerts();
      return Right(alerts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
