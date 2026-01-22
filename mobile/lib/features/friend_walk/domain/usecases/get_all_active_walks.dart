import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/walk_session.dart';
import '../repositories/friend_walk_repository.dart';

class GetAllActiveWalks implements UseCase<List<WalkSession>, NoParams> {
  final FriendWalkRepository repository;

  GetAllActiveWalks(this.repository);

  @override
  Future<Either<Failure, List<WalkSession>>> call(NoParams params) async {
    return await repository.getAllActiveWalks();
  }
}
