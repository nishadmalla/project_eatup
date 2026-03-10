

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/services/hive/hive_service.dart';
import 'package:project_eatup/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<AuthModel> registerUser(AuthModel user) async {
    try {
      await _hiveService.registerUser(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}