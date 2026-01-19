import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/walk_session.dart';
import '../repositories/friend_walk_repository.dart';

class StartWalk implements UseCase<WalkSession, StartWalkParams> {
  final FriendWalkRepository repository;

  StartWalk(this.repository);

  @override
  Future<Either<Failure, WalkSession>> call(StartWalkParams params) async {
    return await repository.startWalk(params.userId, params.guardianId);
  }
}

class StartWalkParams {
  final String userId;
  final String guardianId;
  StartWalkParams({required this.userId, required this.guardianId});
}
