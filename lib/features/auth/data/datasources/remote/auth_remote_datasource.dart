import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/api/api_endpoints.dart';
import 'package:project_eatup/core/api/app_client.dart';
import 'package:project_eatup/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_eatup/features/auth/data/models/auth_api_model.dart';

final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient: apiClient);
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );

      if (response.data["success"] == true) {
        return AuthApiModel.fromJson(response.data);
      }
      return user;
    } on DioException catch (e) {
      // Safely catch registration errors
      throw Exception(e.response?.data["message"] ?? "Failed to register");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      if (response.data["success"] == true) {
        print('Remote Datasource - Parsed AuthApiModel token successfully.');
        return AuthApiModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // CRITICAL FIX: Catch the 401 error gracefully so the app doesn't crash!
      print('Login Failed: ${e.response?.data["message"]}');
      throw Exception(e.response?.data["message"] ?? "Invalid email or password");
    } catch (e) {
      throw Exception("An unexpected error occurred during login.");
    }
  }
}