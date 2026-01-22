import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/campus_compass_repository.dart';

class CampusHeartbeatParams {
  final double lat;
  final double lng;
  final double heading;
  final String status;

  CampusHeartbeatParams({required this.lat, required this.lng, required this.heading, required this.status});
}

class SendHeartbeat implements UseCase<void, CampusHeartbeatParams> {
  final CampusCompassRepository repository;

  SendHeartbeat(this.repository);

  @override
  Future<Either<Failure, void>> call(CampusHeartbeatParams params) async {
    return await repository.sendHeartbeat(params.lat, params.lng, params.heading, params.status);
  }
}
