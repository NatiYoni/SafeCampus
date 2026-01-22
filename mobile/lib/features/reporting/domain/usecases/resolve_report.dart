import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/reporting_repository.dart';

class ResolveReport {
  final ReportingRepository repository;

  ResolveReport(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.resolveReport(id);
  }
}
