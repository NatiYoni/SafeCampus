import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert.dart';

abstract class EmergencyRepository {
  Future<Either<Failure, Alert>> triggerSos(String userId);
  Future<Either<Failure, void>> cancelSos(String alertId);
  Future<Either<Failure, List<Alert>>> getAlerts();
}
