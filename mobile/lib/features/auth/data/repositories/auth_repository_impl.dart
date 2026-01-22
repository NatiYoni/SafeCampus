import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart'; // Import UserModel and ProfileModel

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          return Left(ServerFailure(data['error']));
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register(String email, String password, String fullName, String phoneNumber, String universityId) async {
    try {
      await remoteDataSource.register(email, password, fullName, phoneNumber, universityId);
      return const Right(null);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          return Left(ServerFailure(data['error']));
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String email, String code) async {
    try {
      await remoteDataSource.verifyEmail(email, code);
      return const Right(null);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          return Left(ServerFailure(data['error']));
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerification(String email) async {
    try {
      await remoteDataSource.resendVerification(email);
      return const Right(null);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          return Left(ServerFailure(data['error']));
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getLastUser();
      if (user != null) {
        return Right(user);
      }
      return Left(CacheFailure('No user found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      // Convert User.Profile to ProfileModel
      ProfileModel? profileModel;
      if (user.profile != null) {
        profileModel = ProfileModel(
          bloodType: user.profile!.bloodType,
          allergies: user.profile!.allergies,
          medicalConditions: user.profile!.medicalConditions,
          medications: user.profile!.medications,
        );
      }

      // Cast base User to UserModel
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        universityId: user.universityId,
        isVerified: user.isVerified,
        role: user.role,
        profile: profileModel,
      );
      final updatedUser = await remoteDataSource.updateProfile(userModel);
      return Right(updatedUser);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
         final data = e.response!.data;
         if (data is Map && data.containsKey('error')) {
           return Left(ServerFailure(data['error']));
         }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(oldPassword, newPassword);
      return const Right(null);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
         final data = e.response!.data;
         if (data is Map && data.containsKey('error')) {
           return Left(ServerFailure(data['error']));
         }
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}

