import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/report.dart';

abstract class ReportingRepository {
  Future<Either<Failure, Report>> submitReport(String userId, String category, String description, bool isAnonymous);
  Future<Either<Failure, List<Report>>> getReports();
}
