import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mental_health_resource.dart';

abstract class MentalHealthRepository {
  Future<Either<Failure, List<MentalHealthResource>>> getResources();
}
