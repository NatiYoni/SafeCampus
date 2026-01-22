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

  @override
  Future<Either<Failure, String>> sendChatToCompanion(String message, List<Map<String, String>> history) async {
    try {
      final response = await remoteDataSource.sendMessage(message, history);
      return Right(response);
    } on DioException catch (e) {
      // Extract specific error message from backend if available
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
        final Map<String, dynamic> data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('error')) {
          return Left(ServerFailure(data['error']));
        }
      }
      return Left(ServerFailure(e.message ?? 'Unknown Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

