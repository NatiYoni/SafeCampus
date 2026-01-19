import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert.dart';
import '../repositories/emergency_repository.dart';

class TriggerSos implements UseCase<Alert, String> {
  final EmergencyRepository repository;

  TriggerSos(this.repository);

  @override
  Future<Either<Failure, Alert>> call(String userId) async {
    return await repository.triggerSos(userId);
  }
}
