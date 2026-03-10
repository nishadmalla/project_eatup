
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/error/failures.dart';
import 'package:project_eatup/core/usecases/app_usecases.dart';
import 'package:project_eatup/features/auth/data/repositories/auth_repository.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:project_eatup/features/auth/domain/repositories/auth_repo.dart';

class RegisterUsecasesParam extends Equatable {
  final String name;
  final String email;
  final String password;
const RegisterUsecasesParam({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}


final registerUsecaseProvider = Provider<RegisterUsecases>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecases(authRepository: authRepository);
});


class RegisterUsecases  implements UsecaseWithParams<bool, RegisterUsecasesParam> {
  final IAuthRepository _authRepository;
  RegisterUsecases({required IAuthRepository authRepository}): _authRepository = authRepository;
  @override
  Future<Either<Failure, bool>> call(params) {
    final user =  AuthEntity(
      name: params.name,
      email: params.email,
      password: params.password, role: '', token: '', authId: '',
    );
    return _authRepository.signUp(user);
  }
}