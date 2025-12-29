import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Kakao 로그인 UseCase
class LoginWithKakaoUseCase {
  final AuthRepository repository;

  LoginWithKakaoUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.loginWithKakao();
  }
}
