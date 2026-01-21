import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Either<Failure, void>> call(String email, String password, String fullName, String phoneNumber, String universityId) async {
    return await repository.register(email, password, fullName, phoneNumber, universityId);
  }
}
