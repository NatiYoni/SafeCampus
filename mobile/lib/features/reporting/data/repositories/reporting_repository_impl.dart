import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/reporting_repository.dart';
import '../datasources/reporting_remote_data_source.dart';

class ReportingRepositoryImpl implements ReportingRepository {
  final ReportingRemoteDataSource remoteDataSource;

  ReportingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Report>> submitReport(String userId, String category, String description, bool isAnonymous) async {
    try {
      final report = await remoteDataSource.createReport(userId, category, description, isAnonymous);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getReports() async {
    try {
      final reports = await remoteDataSource.getReports();
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resolveReport(String id) async {
    try {
      await remoteDataSource.resolveReport(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
