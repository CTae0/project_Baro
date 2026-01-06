import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Naver OAuth 로그인 UseCase
class LoginWithNaverUseCase {
  final AuthRepository repository;

  LoginWithNaverUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.loginWithNaver();
  }
}
