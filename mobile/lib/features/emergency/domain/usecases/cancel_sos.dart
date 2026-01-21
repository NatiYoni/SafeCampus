import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/emergency_repository.dart';

class CancelSos implements UseCase<void, String> {
  final EmergencyRepository repository;

  CancelSos(this.repository);

  @override
  Future<Either<Failure, void>> call(String alertId) async {
    return await repository.cancelSos(alertId);
  }
}
