import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mental_health_resource.dart';
import '../../domain/repositories/mental_health_repository.dart';
import '../datasources/mental_health_remote_data_source.dart';

class MentalHealthRepositoryImpl implements MentalHealthRepository {
  final MentalHealthRemoteDataSource remoteDataSource;

  MentalHealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MentalHealthResource>>> getResources() async {
    try {
      final resources = await remoteDataSource.getResources();
      return Right(resources);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
