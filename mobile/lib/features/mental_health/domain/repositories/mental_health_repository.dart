import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mental_health_resource.dart';

abstract class MentalHealthRepository {
  Future<Either<Failure, List<MentalHealthResource>>> getResources();
  Future<Either<Failure, String>> sendChatToCompanion(String message, List<Map<String, String>> history);
}

