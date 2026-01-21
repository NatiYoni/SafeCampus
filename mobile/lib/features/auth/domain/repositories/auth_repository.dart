import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> register(String email, String password, String fullName, String phoneNumber, String universityId);
  Future<Either<Failure, void>> verifyEmail(String email, String code);
  Future<Either<Failure, void>> resendVerification(String email);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
