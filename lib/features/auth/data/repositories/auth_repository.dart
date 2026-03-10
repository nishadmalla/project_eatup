import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/error/failures.dart';
import 'package:project_eatup/core/services/connectivity/network_info.dart';
import 'package:project_eatup/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_eatup/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:project_eatup/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:project_eatup/features/auth/data/models/auth_api_model.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:project_eatup/features/auth/domain/repositories/auth_repo.dart';
import 'package:hive/hive.dart';

/// --------------------------------
/// Provider
/// --------------------------------
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    localDatasource: ref.read(authLocalDatasourceProvider),
    remoteDatasource: ref.read(authRemoteProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// --------------------------------
/// Repository Implementation
/// --------------------------------
class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _localDatasource;
  final IAuthRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource localDatasource,
    required IAuthRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  // -------------------------------
  // LOGIN
  // -------------------------------
  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      // 🌐 Remote login
      try {
        final user =
            await _remoteDatasource.loginUser(email, password);

        if (user == null) {
          return Left(
            ServerFailure(message: "Invalid email or password"),
          );
        }

        return Right(user.toEntity());
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data["message"] ?? "Login failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // 📦 Local login
      try {
        final user =
            await _localDatasource.loginUser(email, password);

        if (user == null) {
          return Left(
            LocalDatabaseFailure(
              message: "Email or password is incorrect",
            ),
          );
        }

        return Right(user.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

// -------------------------------
// REGISTER
// -------------------------------
@override
Future<Either<Failure, bool>> signUp(AuthEntity user) async {
  if (await _networkInfo.isConnected) {
    // 🌐 Remote register
    try {
      // Convert entity → API model
      final apiModel = AuthApiModel.fromEntity(user);

      // Call remote datasource and get registered user
      final registeredUser = await _remoteDatasource.registerUser(apiModel);

      // Convert API model → Hive local model safely
      final localModel = AuthModel.fromApi(registeredUser)
          .copyWith(password: null); // clear password before saving locally

      // Save locally
      await _localDatasource.registerUser(localModel);

      // Registration succeeded
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data["message"] ?? "Registration failed",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  } else {
    // 📦 Local registration (offline)
    try {
      final localModel = AuthModel.fromEntity(user);
      await _localDatasource.registerUser(localModel);
      return const Right(true);
    } on HiveError catch (e) {
      return Left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: "Unexpected error: ${e.toString()}",
        ),
      );
    }
  }
}

}