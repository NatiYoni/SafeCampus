import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mental_health_resource.dart';
import '../repositories/mental_health_repository.dart';

class GetMentalHealthResources implements UseCase<List<MentalHealthResource>, NoParams> {
  final MentalHealthRepository repository;

  GetMentalHealthResources(this.repository);

  @override
  Future<Either<Failure, List<MentalHealthResource>>> call(NoParams params) async {
    return await repository.getResources();
  }
}
