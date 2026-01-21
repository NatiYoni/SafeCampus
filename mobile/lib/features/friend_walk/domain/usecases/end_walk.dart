import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/friend_walk_repository.dart';

class EndWalk implements UseCase<void, String> {
  final FriendWalkRepository repository;

  EndWalk(this.repository);

  @override
  Future<Either<Failure, void>> call(String walkId) async {
    return await repository.endWalk(walkId);
  }
}
