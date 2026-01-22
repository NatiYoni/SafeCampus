import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/campus_presence.dart';
import '../repositories/campus_compass_repository.dart';

class GetCampusStatus implements UseCase<List<CampusPresence>, NoParams> {
  final CampusCompassRepository repository;

  GetCampusStatus(this.repository);

  @override
  Future<Either<Failure, List<CampusPresence>>> call(NoParams params) async {
    return await repository.getCampusStatus();
  }
}
