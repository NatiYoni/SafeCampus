import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/campus_presence.dart';
import '../../domain/repositories/campus_compass_repository.dart';
import '../datasources/campus_compass_remote_data_source.dart';

class CampusCompassRepositoryImpl implements CampusCompassRepository {
  final CampusCompassRemoteDataSource remoteDataSource;

  CampusCompassRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendHeartbeat(double lat, double lng, double heading, String status) async {
    try {
      await remoteDataSource.sendHeartbeat(lat, lng, heading, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CampusPresence>>> getCampusStatus() async {
    try {
      final result = await remoteDataSource.getCampusStatus();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
