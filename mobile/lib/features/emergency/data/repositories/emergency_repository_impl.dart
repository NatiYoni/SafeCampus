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
}
