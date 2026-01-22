import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<Either<Failure, void>> call(String oldPassword, String newPassword) async {
    return await repository.changePassword(oldPassword, newPassword);
  }
}
