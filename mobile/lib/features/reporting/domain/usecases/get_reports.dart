import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report.dart';
import '../repositories/reporting_repository.dart';

class GetReports implements UseCase<List<Report>, NoParams> {
  final ReportingRepository repository;

  GetReports(this.repository);

  @override
  Future<Either<Failure, List<Report>>> call(NoParams params) async {
    return await repository.getReports();
  }
}
