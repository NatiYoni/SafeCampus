import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alert.dart';
import '../repositories/emergency_repository.dart';

class GetMyActiveAlert implements UseCase<Alert?, NoParams> {
  final EmergencyRepository repository;

  GetMyActiveAlert(this.repository);

  @override
  Future<Either<Failure, Alert?>> call(NoParams params) async {
    return await repository.getMyActiveAlert();
  }
}
