

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/error/failures.dart';
import 'package:project_eatup/core/usecases/app_usecases.dart';
import 'package:project_eatup/features/auth/data/repositories/auth_repository.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:project_eatup/features/auth/domain/repositories/auth_repo.dart';

class LoginUsecasesParams extends Equatable {

  final String email;
  final String password;

  const LoginUsecasesParams({
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [email, password];
}


final loginUsecasesProvider = Provider<LoginUsecases>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecases(authRepository: authRepository);
});


class LoginUsecases implements UsecaseWithParams<AuthEntity, LoginUsecasesParams> {
  final IAuthRepository _authRepository;
  LoginUsecases({required IAuthRepository authRepository}): _authRepository = authRepository;
  @override
  Future<Either<Failure, AuthEntity>> call(params) {
    return _authRepository.login(params.email, params.password);
  }
}

