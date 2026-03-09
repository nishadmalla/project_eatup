

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/error/failures.dart';
import 'package:project_eatup/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_eatup/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:project_eatup/features/auth/domain/repositories/auth_repo.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {

  final IAuthDatasource _authDatasource;
  AuthRepository({required IAuthDatasource authDatasource}): _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try{
      final user = await _authDatasource.login(email, password);
      if(user != null){
        return Right(user.toEntity());
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }

  }

  @override
  Future<Either<Failure, bool>> signUp(AuthEntity user) async {
    try{
      final model = AuthModel.fromEntity(user);
      final result = await _authDatasource.signUp(model);
      if(result){
        return Right(true);
      } else {
        return Left(LocalDatabaseFailure(message: "Sign Up failed"));
      }
    }catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
  
}