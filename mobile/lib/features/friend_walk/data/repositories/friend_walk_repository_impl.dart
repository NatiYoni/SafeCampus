import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/walk_session.dart';
import '../../domain/repositories/friend_walk_repository.dart';
import '../datasources/friend_walk_remote_data_source.dart';

class FriendWalkRepositoryImpl implements FriendWalkRepository {
  final FriendWalkRemoteDataSource remoteDataSource;

  FriendWalkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalkSession>> startWalk(String userId, String guardianId) async {
    try {
      final session = await remoteDataSource.startWalk(userId, guardianId);
      return Right(session);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation(String walkId, double lat, double lng) async {
    try {
      await remoteDataSource.updateLocation(walkId, lat, lng);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endWalk(String walkId) async {
    try {
      await remoteDataSource.endWalk(walkId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WalkSession>>> getAllActiveWalks() async {
    try {
      final sessions = await remoteDataSource.getAllActiveWalks();
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
