import 'package:project_eatup/features/auth/data/models/auth_api_model.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';

/// -------------------------------
/// Local Datasource (Hive)
/// -------------------------------
abstract interface class IAuthLocalDatasource {
  Future<AuthModel> registerUser(AuthModel user);
  Future<AuthModel?> loginUser(String email, String password);
}

/// -------------------------------
/// Remote Datasource (API)
/// -------------------------------
abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email, String password);
}
