import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/campus_presence.dart';

abstract class CampusCompassRepository {
  Future<Either<Failure, void>> sendHeartbeat(double lat, double lng, double heading, String status);
  Future<Either<Failure, List<CampusPresence>>> getCampusStatus();
}
