import 'package:dartz/dartz.dart';
import 'package:project_eatup/core/error/failures.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure,bool>> signUp(AuthEntity user);
  Future<Either<Failure,AuthEntity>> login(String email, String password);
}