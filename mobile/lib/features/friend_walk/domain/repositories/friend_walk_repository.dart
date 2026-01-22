import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/walk_session.dart';

abstract class FriendWalkRepository {
  Future<Either<Failure, WalkSession>> startWalk(String userId, String guardianId);
  Future<Either<Failure, void>> updateLocation(String walkId, double lat, double lng);
  Future<Either<Failure, void>> endWalk(String walkId);
  Future<Either<Failure, List<WalkSession>>> getAllActiveWalks();
}
