import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendVerification {
  final AuthRepository repository;

  ResendVerification(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.resendVerification(email);
  }
}
