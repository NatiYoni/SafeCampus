import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert.dart';
import '../repositories/emergency_repository.dart';

class GetAlerts implements UseCase<List<Alert>, NoParams> {
  final EmergencyRepository repository;

  GetAlerts(this.repository);

  @override
  Future<Either<Failure, List<Alert>>> call(NoParams params) async {
    return await repository.getAlerts();
  }
}
