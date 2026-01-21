import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/friend_walk_repository.dart';

class UpdateWalkLocation implements UseCase<void, UpdateWalkLocationParams> {
  final FriendWalkRepository repository;

  UpdateWalkLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateWalkLocationParams params) async {
    return await repository.updateLocation(params.walkId, params.lat, params.lng);
  }
}

class UpdateWalkLocationParams extends Equatable {
  final String walkId;
  final double lat;
  final double lng;

  const UpdateWalkLocationParams({required this.walkId, required this.lat, required this.lng});

  @override
  List<Object> get props => [walkId, lat, lng];
}
