import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 회원가입 UseCase
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String password2,
    String? name,
    String? phoneNumber,
    String? nickname,
    String? role,
  }) {
    return repository.register(
      email: email,
      password: password,
      password2: password2,
      name: name,
      phoneNumber: phoneNumber,
      nickname: nickname,
      role: role,
    );
  }
}
