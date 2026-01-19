import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report.dart';
import '../repositories/reporting_repository.dart';

class SubmitReport implements UseCase<Report, SubmitReportParams> {
  final ReportingRepository repository;

  SubmitReport(this.repository);

  @override
  Future<Either<Failure, Report>> call(SubmitReportParams params) async {
    return await repository.submitReport(
      params.userId,
      params.category,
      params.description,
      params.isAnonymous,
    );
  }
}

class SubmitReportParams {
  final String userId;
  final String category;
  final String description;
  final bool isAnonymous;

  SubmitReportParams({
    required this.userId,
    required this.category,
    required this.description,
    required this.isAnonymous,
  });
}
